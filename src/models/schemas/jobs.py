"""Job orchestration Pydantic schemas."""

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import Field

from src.models.schemas.common import BaseSchema


class JobCreate(BaseSchema):
    name: str = Field(..., min_length=1, max_length=255)
    job_type: str = Field(..., pattern="^(export|load|refresh|dependency_scan)$")
    description: str | None = None
    schedule_cron: str | None = None
    config: dict[str, Any] = {}
    max_retries: int = Field(default=3, ge=0, le=10)
    timeout_seconds: int = Field(default=3600, ge=60, le=86400)


class JobUpdate(BaseSchema):
    name: str | None = Field(default=None, min_length=1, max_length=255)
    description: str | None = None
    schedule_cron: str | None = None
    config: dict[str, Any] | None = None
    is_enabled: bool | None = None
    max_retries: int | None = Field(default=None, ge=0, le=10)
    timeout_seconds: int | None = Field(default=None, ge=60, le=86400)


class JobResponse(BaseSchema):
    id: UUID
    name: str
    job_type: str
    description: str | None
    schedule_cron: str | None
    config: dict[str, Any]
    is_enabled: bool
    max_retries: int
    timeout_seconds: int
    created_at: datetime
    updated_at: datetime


class JobRunResponse(BaseSchema):
    id: UUID
    job_id: UUID
    status: str
    triggered_by: str
    started_at: datetime | None
    completed_at: datetime | None
    duration_seconds: float | None
    records_processed: int
    records_failed: int
    error_message: str | None
    retry_count: int
    metadata_json: dict[str, Any]
    created_at: datetime


class JobStepResponse(BaseSchema):
    id: UUID
    job_run_id: UUID
    step_name: str
    step_order: int
    status: str
    started_at: datetime | None
    completed_at: datetime | None
    duration_seconds: float | None
    records_in: int
    records_out: int
    error_message: str | None


class TriggerJobRequest(BaseSchema):
    job_id: UUID
    params: dict[str, Any] = {}


class TriggerJobResponse(BaseSchema):
    job_run_id: UUID
    status: str = "queued"
    message: str = "Job queued for execution"
