"""
Scheduler Service.
Runs as a standalone process to trigger jobs based on cron schedules.
Replaces external cron-based script execution.
"""

import asyncio
import signal
import sys
from datetime import datetime

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger

from src.config.logging import get_logger, setup_logging
from src.config.settings import get_settings
from src.db.postgres import AsyncSessionLocal
from src.db.redis import enqueue_job
from src.repositories.job_repo import JobRepository

logger = get_logger(__name__)


class SchedulerService:
    """Manages cron-based job scheduling via APScheduler."""

    def __init__(self):
        self.scheduler = AsyncIOScheduler()
        self.settings = get_settings()
        self._running = True

    async def load_schedules(self) -> None:
        """Load all enabled scheduled jobs from the database and register them."""
        async with AsyncSessionLocal() as session:
            repo = JobRepository(session)
            scheduled_jobs = await repo.get_scheduled_jobs()

            for job in scheduled_jobs:
                if not job.schedule_cron:
                    continue

                try:
                    trigger = CronTrigger.from_crontab(job.schedule_cron)
                    self.scheduler.add_job(
                        self._trigger_job,
                        trigger=trigger,
                        id=str(job.id),
                        name=job.name,
                        kwargs={
                            "job_id": str(job.id),
                            "job_type": job.job_type,
                            "job_name": job.name,
                            "config": job.config,
                            "max_retries": job.max_retries,
                            "timeout_seconds": job.timeout_seconds,
                        },
                        replace_existing=True,
                    )
                    logger.info(
                        "job_scheduled",
                        name=job.name,
                        cron=job.schedule_cron,
                        job_type=job.job_type,
                    )
                except Exception as e:
                    logger.error(
                        "schedule_registration_failed",
                        name=job.name,
                        cron=job.schedule_cron,
                        error=str(e),
                    )

            logger.info(
                "schedules_loaded",
                total=len(scheduled_jobs),
            )

    async def _trigger_job(
        self,
        job_id: str,
        job_type: str,
        job_name: str,
        config: dict,
        max_retries: int,
        timeout_seconds: int,
    ) -> None:
        """Enqueue a scheduled job for worker execution."""
        try:
            # Create a job run record
            async with AsyncSessionLocal() as session:
                from src.repositories.job_repo import JobRunRepository
                from uuid import UUID

                run_repo = JobRunRepository(session)
                job_run = await run_repo.create(
                    job_id=UUID(job_id),
                    status="pending",
                    triggered_by="scheduler",
                    metadata_json={"scheduled_at": datetime.now().isoformat()},
                )
                await session.commit()

                # Enqueue to Redis
                await enqueue_job(
                    job_type=job_type,
                    payload={
                        "job_id": job_id,
                        "job_run_id": str(job_run.id),
                        "job_type": job_type,
                        "config": config,
                        "params": {},
                        "max_retries": max_retries,
                        "timeout_seconds": timeout_seconds,
                    },
                )

                logger.info(
                    "scheduled_job_triggered",
                    job_name=job_name,
                    job_run_id=str(job_run.id),
                )

        except Exception as e:
            logger.error(
                "scheduled_trigger_failed",
                job_name=job_name,
                error=str(e),
            )

    async def start(self) -> None:
        """Start the scheduler."""
        await self.load_schedules()
        self.scheduler.start()
        logger.info("scheduler_started")

        # Keep running until stopped
        while self._running:
            await asyncio.sleep(1)

    def stop(self) -> None:
        """Stop the scheduler gracefully."""
        self._running = False
        self.scheduler.shutdown(wait=True)
        logger.info("scheduler_stopped")


async def main() -> None:
    """Entry point for the scheduler process."""
    setup_logging()
    logger.info("scheduler_process_starting")

    scheduler = SchedulerService()

    # Handle graceful shutdown
    loop = asyncio.get_event_loop()

    def shutdown_handler(sig: signal.Signals) -> None:
        logger.info("shutdown_signal_received", signal=sig.name)
        scheduler.stop()

    for sig in (signal.SIGTERM, signal.SIGINT):
        loop.add_signal_handler(sig, shutdown_handler, sig)

    await scheduler.start()


if __name__ == "__main__":
    asyncio.run(main())
