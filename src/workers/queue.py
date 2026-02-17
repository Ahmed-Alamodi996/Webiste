"""
Redis-based job queue worker.
Runs as a standalone process, consuming jobs from Redis queues.
Each job type has its own dedicated handler.
"""

import asyncio
import signal
import sys
import traceback
from typing import Any
from uuid import UUID

from src.config.logging import get_logger, setup_logging
from src.config.settings import get_settings
from src.db.postgres import AsyncSessionLocal
from src.db.redis import dequeue_job, update_job_status
from src.workers.export_worker import handle_export_job
from src.workers.loader_worker import handle_loader_job
from src.workers.refresh_worker import handle_refresh_job

logger = get_logger(__name__)

# Map job types to handler functions
JOB_HANDLERS = {
    "export": handle_export_job,
    "load": handle_loader_job,
    "refresh": handle_refresh_job,
    "dependency_scan": handle_refresh_job,  # Reuses refresh worker for scan
}


class WorkerPool:
    """Manages a pool of async workers consuming from Redis queues."""

    def __init__(self):
        self.settings = get_settings()
        self._running = True
        self._tasks: list[asyncio.Task] = []

    async def start(self) -> None:
        """Start worker pool with one consumer per job type."""
        logger.info(
            "worker_pool_starting",
            job_types=list(JOB_HANDLERS.keys()),
            parallel_workers=self.settings.job_parallel_workers,
        )

        # Create one consumer task per job type
        for job_type in JOB_HANDLERS:
            task = asyncio.create_task(
                self._consume_queue(job_type),
                name=f"worker-{job_type}",
            )
            self._tasks.append(task)

        logger.info("worker_pool_started", consumers=len(self._tasks))

        # Wait for all tasks
        await asyncio.gather(*self._tasks, return_exceptions=True)

    async def _consume_queue(self, job_type: str) -> None:
        """Continuously consume jobs from a specific queue."""
        logger.info("queue_consumer_started", job_type=job_type)

        while self._running:
            try:
                message = await dequeue_job(job_type, timeout=10)
                if message is None:
                    continue  # Timeout, loop again

                job_id = message.get("job_id", "unknown")
                job_run_id = message.get("payload", {}).get("job_run_id")

                logger.info(
                    "job_dequeued",
                    job_id=job_id,
                    job_type=job_type,
                    job_run_id=job_run_id,
                )

                await self._execute_job(job_type, message)

            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(
                    "queue_consumer_error",
                    job_type=job_type,
                    error=str(e),
                    traceback=traceback.format_exc(),
                )
                await asyncio.sleep(5)  # Back off on error

        logger.info("queue_consumer_stopped", job_type=job_type)

    async def _execute_job(
        self, job_type: str, message: dict[str, Any]
    ) -> None:
        """Execute a single job with error handling and status tracking."""
        payload = message.get("payload", {})
        job_run_id = payload.get("job_run_id")

        handler = JOB_HANDLERS.get(job_type)
        if handler is None:
            logger.error("unknown_job_type", job_type=job_type)
            return

        async with AsyncSessionLocal() as session:
            try:
                # Mark as running
                if job_run_id:
                    from src.repositories.job_repo import JobRunRepository

                    run_repo = JobRunRepository(session)
                    await run_repo.start_run(UUID(job_run_id))
                    await session.commit()
                    await update_job_status(job_run_id, "running")

                # Execute the handler
                result = await handler(payload, session)

                # Mark as success
                if job_run_id:
                    run_repo = JobRunRepository(session)
                    await run_repo.complete_run(
                        UUID(job_run_id),
                        status="success",
                        records_processed=result.get("records_processed", 0),
                    )
                    await session.commit()
                    await update_job_status(job_run_id, "success")

                logger.info(
                    "job_completed",
                    job_run_id=job_run_id,
                    job_type=job_type,
                    result=result,
                )

            except Exception as e:
                error_msg = str(e)[:2000]
                logger.error(
                    "job_failed",
                    job_run_id=job_run_id,
                    job_type=job_type,
                    error=error_msg,
                    traceback=traceback.format_exc(),
                )

                if job_run_id:
                    try:
                        await session.rollback()
                        run_repo = JobRunRepository(session)
                        await run_repo.complete_run(
                            UUID(job_run_id),
                            status="failed",
                            error_message=error_msg,
                        )
                        await session.commit()
                        await update_job_status(job_run_id, "failed")
                    except Exception as inner_e:
                        logger.error(
                            "status_update_failed",
                            job_run_id=job_run_id,
                            error=str(inner_e),
                        )

    def stop(self) -> None:
        """Signal all workers to stop."""
        self._running = False
        for task in self._tasks:
            task.cancel()
        logger.info("worker_pool_stopping")


async def main() -> None:
    """Entry point for the worker process."""
    setup_logging()
    logger.info("worker_process_starting")

    pool = WorkerPool()

    # Handle graceful shutdown
    loop = asyncio.get_event_loop()

    def shutdown_handler(sig: signal.Signals) -> None:
        logger.info("shutdown_signal_received", signal=sig.name)
        pool.stop()

    for sig in (signal.SIGTERM, signal.SIGINT):
        loop.add_signal_handler(sig, shutdown_handler, sig)

    await pool.start()
    logger.info("worker_process_stopped")


if __name__ == "__main__":
    asyncio.run(main())
