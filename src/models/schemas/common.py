"""Shared Pydantic schemas used across the API."""

from datetime import datetime
from typing import Any, Generic, TypeVar
from uuid import UUID

from pydantic import BaseModel, ConfigDict

T = TypeVar("T")


class BaseSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class PaginatedResponse(BaseSchema, Generic[T]):
    items: list[T]
    total: int
    page: int
    page_size: int
    total_pages: int


class StatusResponse(BaseSchema):
    status: str
    message: str
    details: dict[str, Any] = {}


class IDResponse(BaseSchema):
    id: UUID
    message: str = "Created successfully"


class ErrorResponse(BaseSchema):
    error: str
    message: str
    details: dict[str, Any] = {}


class HealthResponse(BaseSchema):
    status: str  # healthy | degraded | unhealthy
    version: str
    environment: str
    uptime_seconds: float
    checks: dict[str, str]  # component -> status


class MetricsResponse(BaseSchema):
    timestamp: datetime
    jobs_running: int
    jobs_queued: int
    jobs_completed_24h: int
    jobs_failed_24h: int
    oracle_pool_busy: int
    oracle_pool_open: int
    redis_connected: bool
    postgres_connected: bool
