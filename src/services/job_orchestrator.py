"""
Job Orchestrator Service.
Central coordination for all job types: export, load, refresh, dependency scan.
Manages job lifecycle, retry logic, and failure handling.
"""

import traceback
from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.core.exceptions import JobAlreadyRunningError, JobError, NotFoundError
from src.db.redis import enqueue_job, update_job_status
from src.repositories.audit_repo import AuditLogRepository, ErrorLogRepository
from src.repositories.job_repo import JobRepository, JobRunRepository, JobStepRepository

logger = get_logger(__name__)


class JobOrchestratorService:
    """Orchestrates job execution with full lifecycle management."""

    def __init__(self, session: AsyncSession):
        self.session = session
        self.job_repo = JobRepository(session)
        self.run_repo = JobRunRepository(session)
        self.step_repo = JobStepRepository(session)
        self.audit_repo = AuditLogRepository(session)
        self.error_repo = ErrorLogRepository(session)

    async def trigger_job(
        self,
        job_id: UUID,
        triggered_by: str = "api",
        params: dict[str, Any] | None = None,
        user_id: UUID | None = None,
    ) -> dict[str, Any]:
        """
        Trigger a job for execution. Creates a job_run record
        and enqueues the job for a worker to pick up.
        """
        job = await self.job_repo.get_by_id(job_id)
        if job is None:
            raise NotFoundError(f"Job {job_id} not found")

        if not job.is_enabled:
            raise JobError(
                f"Job '{job.name}' is disabled",
                details={"job_id": str(job_id)},
            )

        # Check for already-running instances
        active_runs = await self.run_repo.get_active_runs()
        for run in active_runs:
            if run.job_id == job_id and run.status == "running":
                raise JobAlreadyRunningError(
                    f"Job '{job.name}' is already running",
                    details={"active_run_id": str(run.id)},
                )

        # Create job run record
        job_run = await self.run_repo.create(
            job_id=job_id,
            status="pending",
            triggered_by=triggered_by,
            metadata_json=params or {},
        )

        # Enqueue to Redis for worker pickup
        redis_job_id = await enqueue_job(
            job_type=job.job_type,
            payload={
                "job_id": str(job_id),
                "job_run_id": str(job_run.id),
                "job_type": job.job_type,
                "config": job.config,
                "params": params or {},
                "max_retries": job.max_retries,
                "timeout_seconds": job.timeout_seconds,
            },
        )

        # Audit trail
        await self.audit_repo.log_action(
            action="job.triggered",
            user_id=user_id,
            resource_type="job",
            resource_id=str(job_id),
            details={
                "job_name": job.name,
                "job_type": job.job_type,
                "triggered_by": triggered_by,
                "job_run_id": str(job_run.id),
            },
        )

        logger.info(
            "job_triggered",
            job_id=str(job_id),
            job_name=job.name,
            job_run_id=str(job_run.id),
            triggered_by=triggered_by,
        )

        return {
            "job_run_id": str(job_run.id),
            "status": "queued",
            "message": f"Job '{job.name}' queued for execution",
        }

    async def start_run(self, job_run_id: UUID) -> None:
        """Mark a job run as started (called by worker)."""
        await self.run_repo.start_run(job_run_id)
        await update_job_status(str(job_run_id), "running")

        logger.info("job_run_started", job_run_id=str(job_run_id))

    async def complete_run(
        self,
        job_run_id: UUID,
        status: str,
        records_processed: int = 0,
        records_failed: int = 0,
        error_message: str | None = None,
    ) -> None:
        """Mark a job run as completed/failed (called by worker)."""
        run = await self.run_repo.complete_run(
            job_run_id,
            status=status,
            records_processed=records_processed,
            records_failed=records_failed,
            error_message=error_message,
        )

        await update_job_status(str(job_run_id), status)

        if status == "failed" and error_message:
            await self.error_repo.log_error(
                error_code="JOB_FAILED",
                source_service="job_orchestrator",
                message=error_message,
                job_run_id=job_run_id,
            )

        logger.info(
            "job_run_completed",
            job_run_id=str(job_run_id),
            status=status,
            records_processed=records_processed,
        )

    async def create_step(
        self, job_run_id: UUID, step_name: str, step_order: int
    ) -> UUID:
        """Create a job step for tracking progress within a run."""
        step = await self.step_repo.create(
            job_run_id=job_run_id,
            step_name=step_name,
            step_order=step_order,
            status="pending",
        )
        return step.id

    async def start_step(self, step_id: UUID) -> None:
        """Mark a step as running."""
        await self.step_repo.update(
            step_id,
            status="running",
            started_at=datetime.now(timezone.utc),
        )

    async def complete_step(
        self,
        step_id: UUID,
        status: str,
        records_in: int = 0,
        records_out: int = 0,
        error_message: str | None = None,
    ) -> None:
        """Mark a step as completed/failed."""
        await self.step_repo.complete_step(
            step_id, status, records_in, records_out, error_message
        )

    async def get_run_status(self, job_run_id: UUID) -> dict[str, Any]:
        """Get comprehensive status of a job run including all steps."""
        run = await self.run_repo.get_by_id(job_run_id)
        if run is None:
            raise NotFoundError(f"Job run {job_run_id} not found")

        steps = await self.step_repo.get_steps_for_run(job_run_id)

        return {
            "run_id": str(run.id),
            "job_id": str(run.job_id),
            "status": run.status,
            "triggered_by": run.triggered_by,
            "started_at": run.started_at.isoformat() if run.started_at else None,
            "completed_at": run.completed_at.isoformat() if run.completed_at else None,
            "duration_seconds": float(run.duration_seconds) if run.duration_seconds else None,
            "records_processed": run.records_processed,
            "records_failed": run.records_failed,
            "error_message": run.error_message,
            "retry_count": run.retry_count,
            "steps": [
                {
                    "step_name": s.step_name,
                    "step_order": s.step_order,
                    "status": s.status,
                    "records_in": s.records_in,
                    "records_out": s.records_out,
                    "duration_seconds": float(s.duration_seconds) if s.duration_seconds else None,
                    "error_message": s.error_message,
                }
                for s in steps
            ],
        }
