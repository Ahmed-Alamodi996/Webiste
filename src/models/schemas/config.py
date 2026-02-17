"""Configuration Pydantic schemas."""

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import Field

from src.models.schemas.common import BaseSchema


class TableConfigCreate(BaseSchema):
    name: str = Field(..., min_length=1, max_length=255)
    source_type: str = Field(..., pattern="^(postgres|csv|excel|oracle)$")
    source_connection_id: UUID | None = None
    source_table_name: str = Field(..., min_length=1)
    source_columns: str
    where_condition: str | None = None
    destination_connection_id: UUID | None = None
    destination_table_name: str = Field(..., min_length=1)
    destination_columns: str
    date_format: str | None = None
    date_column: str | None = None
    schedule_day: int | None = Field(default=None, ge=1, le=31)
    skip_rows: int = Field(default=0, ge=0)
    file_name_pattern: str | None = None
    file_extension_filter: str | None = None
    backup_folder: str | None = None
    config_json: dict[str, Any] = {}


class TableConfigUpdate(BaseSchema):
    name: str | None = None
    source_columns: str | None = None
    where_condition: str | None = None
    destination_columns: str | None = None
    date_format: str | None = None
    schedule_day: int | None = Field(default=None, ge=1, le=31)
    skip_rows: int | None = None
    is_enabled: bool | None = None
    config_json: dict[str, Any] | None = None


class TableConfigResponse(BaseSchema):
    id: UUID
    name: str
    source_type: str
    source_table_name: str
    source_columns: str
    where_condition: str | None
    destination_table_name: str
    destination_columns: str
    date_format: str | None
    schedule_day: int | None
    skip_rows: int
    is_enabled: bool
    created_at: datetime
    updated_at: datetime


class ConnectionProfileCreate(BaseSchema):
    name: str = Field(..., min_length=1, max_length=100)
    db_type: str = Field(..., pattern="^(oracle|postgresql)$")
    host: str
    port: int = Field(ge=1, le=65535)
    database_name: str
    username: str
    password_env_var: str = Field(
        ..., description="Environment variable name holding the password"
    )
    extra_params: dict[str, Any] = {}


class ConnectionProfileResponse(BaseSchema):
    id: UUID
    name: str
    db_type: str
    host: str
    port: int
    database_name: str
    username: str
    password_env_var: str
    is_active: bool
    created_at: datetime


class DependencyGraphResponse(BaseSchema):
    object_name: str
    object_type: str
    depends_on: str
    depends_on_type: str
    topo_level: int | None
    scanned_at: datetime


class MVRefreshStatusResponse(BaseSchema):
    id: UUID
    mv_name: str
    refresh_type: str
    status: str
    topo_level: int | None
    started_at: datetime | None
    completed_at: datetime | None
    duration_seconds: float | None
    error_message: str | None
    retry_count: int
