"""Dependency graph, MV refresh status, and MV refresh sequence SQLAlchemy models."""

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Integer, Numeric, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from src.db.postgres import Base


class DependencyEdge(Base):
    """Directed edge in the view/MV dependency graph."""

    __tablename__ = "dependency_graph"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    object_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    object_type: Mapped[str] = mapped_column(
        String(50), nullable=False
    )  # VIEW | MATERIALIZED VIEW
    depends_on: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    depends_on_type: Mapped[str] = mapped_column(String(50), nullable=False)
    topo_level: Mapped[int | None] = mapped_column(Integer)
    scan_run_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    scanned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class MVRefreshStatus(Base):
    """Materialized view refresh execution tracking."""

    __tablename__ = "mv_refresh_status"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    mv_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    refresh_type: Mapped[str] = mapped_column(
        String(20), default="COMPLETE"
    )  # COMPLETE | FAST | FORCE
    status: Mapped[str] = mapped_column(
        String(30), nullable=False, default="pending"
    )  # pending | running | success | failed | timeout | skipped
    topo_level: Mapped[int | None] = mapped_column(Integer)
    job_run_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), index=True)
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    duration_seconds: Mapped[float | None] = mapped_column(Numeric(12, 3))
    error_message: Mapped[str | None] = mapped_column(Text)
    retry_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class MVRefreshSequence(Base):
    """Static MV refresh sequence (migrated from sequence_updated3.xlsx).
    Serves as fallback when dynamic dependency scanning is unavailable.
    485 materialized views in proven dependency-sorted refresh order.
    """

    __tablename__ = "mv_refresh_sequence"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    mv_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    refresh_order: Mapped[int] = mapped_column(Integer, nullable=False)
    refresh_type: Mapped[str] = mapped_column(String(20), default="COMPLETE")
    timeout_seconds: Mapped[int] = mapped_column(Integer, default=3600)
    is_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
