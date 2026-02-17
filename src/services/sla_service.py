"""SLA Service: tracks compliance and detects breaches."""

from datetime import datetime, timezone
from typing import Any, Sequence
from uuid import UUID

from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.config.settings import get_settings
from src.models.domain.jobs import JobRun
from src.models.domain.sla import SLAPolicy, SLATracking
from src.repositories.base import BaseRepository

logger = get_logger(__name__)


class SLAService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.policy_repo = BaseRepository(SLAPolicy, session)
        self.tracking_repo = BaseRepository(SLATracking, session)
        self.settings = get_settings()

    async def evaluate_job_run(self, job_run: JobRun, job_type: str) -> SLATracking | None:
        """Evaluate SLA compliance for a completed job run."""
        if not job_run.completed_at or not job_run.started_at:
            return None

        # Find applicable SLA policy
        result = await self.session.execute(
            select(SLAPolicy).where(SLAPolicy.job_type == job_type)
        )
        policy = result.scalar_one_or_none()
        if policy is None:
            return None

        actual_minutes = (
            job_run.completed_at - job_run.started_at
        ).total_seconds() / 60

        is_breached = actual_minutes > policy.max_duration_minutes
        breach_reason = None
        breach_details: dict[str, Any] = {}

        if is_breached:
            breach_reason = (
                f"Duration {actual_minutes:.1f}m exceeds SLA "
                f"threshold of {policy.max_duration_minutes}m"
            )
            breach_details = {
                "expected_minutes": policy.max_duration_minutes,
                "actual_minutes": round(actual_minutes, 2),
                "overage_minutes": round(
                    actual_minutes - policy.max_duration_minutes, 2
                ),
            }

            logger.warning(
                "sla_breach_detected",
                job_run_id=str(job_run.id),
                job_type=job_type,
                expected=policy.max_duration_minutes,
                actual=round(actual_minutes, 2),
            )

        tracking = SLATracking(
            sla_policy_id=policy.id,
            job_run_id=job_run.id,
            expected_duration_minutes=policy.max_duration_minutes,
            actual_duration_minutes=round(actual_minutes, 2),
            is_breached=is_breached,
            breach_reason=breach_reason,
            breach_details=breach_details,
        )
        self.session.add(tracking)
        await self.session.flush()
        return tracking

    async def get_breaches(
        self, limit: int = 50, job_type: str | None = None
    ) -> Sequence[SLATracking]:
        query = select(SLATracking).where(SLATracking.is_breached.is_(True))
        if job_type:
            query = query.join(SLAPolicy).where(SLAPolicy.job_type == job_type)
        query = query.order_by(SLATracking.evaluated_at.desc()).limit(limit)
        result = await self.session.execute(query)
        return result.scalars().all()

    async def get_compliance_summary(self) -> dict[str, Any]:
        """Get SLA compliance stats for the dashboard."""
        from sqlalchemy import func

        # Total runs evaluated
        total_result = await self.session.execute(
            select(func.count(SLATracking.id))
        )
        total = total_result.scalar() or 0

        # Breached runs
        breached_result = await self.session.execute(
            select(func.count(SLATracking.id)).where(
                SLATracking.is_breached.is_(True)
            )
        )
        breached = breached_result.scalar() or 0

        compliance_rate = ((total - breached) / total * 100) if total > 0 else 100.0

        return {
            "total_evaluated": total,
            "total_breached": breached,
            "compliance_rate_percent": round(compliance_rate, 2),
        }
