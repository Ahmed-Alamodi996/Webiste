"""SLA tracking SQLAlchemy models."""

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Integer, Numeric, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from src.db.postgres import Base


class SLAPolicy(Base):
    """Defines SLA thresholds for each job type."""

    __tablename__ = "sla_policies"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    job_type: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    max_duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    max_failure_rate_percent: Mapped[float | None] = mapped_column(Numeric(5, 2))
    min_records_threshold: Mapped[int | None] = mapped_column(Integer)
    alert_on_breach: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class SLATracking(Base):
    """Records SLA compliance for each job run."""

    __tablename__ = "sla_tracking"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    sla_policy_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    job_run_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    expected_duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    actual_duration_minutes: Mapped[float | None] = mapped_column(Numeric(10, 2))
    is_breached: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    breach_reason: Mapped[str | None] = mapped_column(Text)
    breach_details: Mapped[dict] = mapped_column(JSONB, default=dict)
    evaluated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
