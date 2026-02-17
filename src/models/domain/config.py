"""Configuration SQLAlchemy models: table mappings, connection profiles, data quality."""

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from src.db.postgres import Base


class ConnectionProfile(Base):
    """Database connection profiles (replaces hardcoded credentials)."""

    __tablename__ = "connection_profiles"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    db_type: Mapped[str] = mapped_column(
        String(30), nullable=False
    )  # oracle | postgresql
    host: Mapped[str] = mapped_column(String(255), nullable=False)
    port: Mapped[int] = mapped_column(Integer, nullable=False)
    database_name: Mapped[str] = mapped_column(String(255), nullable=False)
    username: Mapped[str] = mapped_column(String(255), nullable=False)
    # Password stored as env var reference, NOT plaintext
    password_env_var: Mapped[str] = mapped_column(String(255), nullable=False)
    extra_params: Mapped[dict] = mapped_column(JSONB, default=dict)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class TableConfig(Base):
    """ETL table configuration (replaces data_mapping.xlsx)."""

    __tablename__ = "table_config"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    source_type: Mapped[str] = mapped_column(
        String(30), nullable=False
    )  # postgres | csv | excel | oracle
    source_connection_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    source_table_name: Mapped[str] = mapped_column(String(500), nullable=False)
    source_columns: Mapped[str] = mapped_column(Text, nullable=False)
    where_condition: Mapped[str | None] = mapped_column(Text)
    destination_connection_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    destination_table_name: Mapped[str] = mapped_column(String(500), nullable=False)
    destination_columns: Mapped[str] = mapped_column(Text, nullable=False)
    date_format: Mapped[str | None] = mapped_column(String(50))
    date_column: Mapped[str | None] = mapped_column(String(255))
    schedule_day: Mapped[int | None] = mapped_column(Integer)
    skip_rows: Mapped[int] = mapped_column(Integer, default=0)
    file_name_pattern: Mapped[str | None] = mapped_column(String(500))
    file_extension_filter: Mapped[str | None] = mapped_column(String(50))
    backup_folder: Mapped[str | None] = mapped_column(String(500))
    is_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    config_json: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class DataQualityRule(Base):
    """Data quality validation rules for ETL pipelines."""

    __tablename__ = "data_quality_rules"
    __table_args__ = {"schema": "ra_meta"}

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    table_config_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    rule_name: Mapped[str] = mapped_column(String(255), nullable=False)
    rule_type: Mapped[str] = mapped_column(
        String(50), nullable=False
    )  # not_null | unique | range | regex | row_count
    column_name: Mapped[str | None] = mapped_column(String(255))
    rule_expression: Mapped[str] = mapped_column(Text, nullable=False)
    severity: Mapped[str] = mapped_column(
        String(20), default="warning"
    )  # warning | error | critical
    is_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
