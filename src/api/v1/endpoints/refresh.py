"""MV Refresh API endpoints."""

from fastapi import APIRouter
from pydantic import BaseModel, Field

from src.api.deps import DBSession, require_permission
from src.models.schemas.config import MVRefreshStatusResponse
from src.repositories.config_repo import MVRefreshStatusRepository
from src.services.mv_refresh import MVRefreshService

router = APIRouter()


class RefreshSingleRequest(BaseModel):
    mv_name: str
    refresh_type: str = Field(default="COMPLETE", pattern="^(COMPLETE|FAST|FORCE)$")


class RefreshAllRequest(BaseModel):
    refresh_plan: list[list[str]]
    refresh_type: str = Field(default="COMPLETE", pattern="^(COMPLETE|FAST|FORCE)$")
    max_parallel: int = Field(default=4, ge=1, le=32)
    timeout_per_mv: int = Field(default=3600, ge=60, le=86400)


@router.post(
    "/single",
    dependencies=[require_permission("refresh:execute")],
)
async def refresh_single_mv(data: RefreshSingleRequest):
    """Refresh a single materialized view."""
    service = MVRefreshService()
    return await service.refresh_single(data.mv_name, data.refresh_type)


@router.post(
    "/all",
    dependencies=[require_permission("refresh:execute")],
)
async def refresh_all_mvs(data: RefreshAllRequest):
    """Refresh all MVs in dependency order with parallel execution per level."""
    service = MVRefreshService()
    return await service.refresh_all(
        refresh_plan=data.refresh_plan,
        refresh_type=data.refresh_type,
        max_parallel=data.max_parallel,
        timeout_per_mv=data.timeout_per_mv,
    )


@router.get(
    "/status/{job_run_id}",
    response_model=list[MVRefreshStatusResponse],
    dependencies=[require_permission("jobs:read")],
)
async def get_refresh_status(job_run_id: str, session: DBSession):
    """Get MV refresh status for a specific job run."""
    from uuid import UUID

    repo = MVRefreshStatusRepository(session)
    results = await repo.get_by_job_run(UUID(job_run_id))
    return [MVRefreshStatusResponse.model_validate(r) for r in results]
