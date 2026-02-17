"""Job, JobRun, and JobStep repository."""

from datetime import datetime, timezone
from typing import Sequence
from uuid import UUID

from sqlalchemy import and_, desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.domain.jobs import Job, JobRun, JobStep
from src.repositories.base import BaseRepository


class JobRepository(BaseRepository[Job]):
    def __init__(self, session: AsyncSession):
        super().__init__(Job, session)

    async def get_by_name(self, name: str) -> Job | None:
        result = await self.session.execute(
            select(Job).where(Job.name == name)
        )
        return result.scalar_one_or_none()

    async def get_enabled_by_type(self, job_type: str) -> Sequence[Job]:
        result = await self.session.execute(
            select(Job).where(
                and_(Job.job_type == job_type, Job.is_enabled.is_(True))
            )
        )
        return result.scalars().all()

    async def get_scheduled_jobs(self) -> Sequence[Job]:
        result = await self.session.execute(
            select(Job).where(
                and_(
                    Job.is_enabled.is_(True),
                    Job.schedule_cron.isnot(None),
                )
            )
        )
        return result.scalars().all()


class JobRunRepository(BaseRepository[JobRun]):
    def __init__(self, session: AsyncSession):
        super().__init__(JobRun, session)

    async def get_runs_for_job(
        self, job_id: UUID, limit: int = 20
    ) -> Sequence[JobRun]:
        result = await self.session.execute(
            select(JobRun)
            .where(JobRun.job_id == job_id)
            .order_by(desc(JobRun.created_at))
            .limit(limit)
        )
        return result.scalars().all()

    async def get_active_runs(self) -> Sequence[JobRun]:
        result = await self.session.execute(
            select(JobRun).where(
                JobRun.status.in_(["pending", "running"])
            )
        )
        return result.scalars().all()

    async def start_run(self, run_id: UUID) -> JobRun | None:
        return await self.update(
            run_id,
            status="running",
            started_at=datetime.now(timezone.utc),
        )

    async def complete_run(
        self,
        run_id: UUID,
        status: str,
        records_processed: int = 0,
        records_failed: int = 0,
        error_message: str | None = None,
    ) -> JobRun | None:
        now = datetime.now(timezone.utc)
        run = await self.get_by_id(run_id)
        if run is None:
            return None

        duration = None
        if run.started_at:
            duration = (now - run.started_at).total_seconds()

        return await self.update(
            run_id,
            status=status,
            completed_at=now,
            duration_seconds=duration,
            records_processed=records_processed,
            records_failed=records_failed,
            error_message=error_message,
        )

    async def count_by_status_last_24h(self) -> dict[str, int]:
        from sqlalchemy import func

        cutoff = datetime.now(timezone.utc).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
        result = await self.session.execute(
            select(JobRun.status, func.count(JobRun.id))
            .where(JobRun.created_at >= cutoff)
            .group_by(JobRun.status)
        )
        return {status: count for status, count in result.all()}


class JobStepRepository(BaseRepository[JobStep]):
    def __init__(self, session: AsyncSession):
        super().__init__(JobStep, session)

    async def get_steps_for_run(self, job_run_id: UUID) -> Sequence[JobStep]:
        result = await self.session.execute(
            select(JobStep)
            .where(JobStep.job_run_id == job_run_id)
            .order_by(JobStep.step_order)
        )
        return result.scalars().all()

    async def complete_step(
        self,
        step_id: UUID,
        status: str,
        records_in: int = 0,
        records_out: int = 0,
        error_message: str | None = None,
    ) -> JobStep | None:
        now = datetime.now(timezone.utc)
        step = await self.get_by_id(step_id)
        if step is None:
            return None

        duration = None
        if step.started_at:
            duration = (now - step.started_at).total_seconds()

        return await self.update(
            step_id,
            status=status,
            completed_at=now,
            duration_seconds=duration,
            records_in=records_in,
            records_out=records_out,
            error_message=error_message,
        )
