"""Job management endpoints: CRUD, trigger, status."""

from uuid import UUID

from fastapi import APIRouter

from src.api.deps import CurrentUser, DBSession, require_permission
from src.models.schemas.common import IDResponse, PaginatedResponse, StatusResponse
from src.models.schemas.jobs import (
    JobCreate,
    JobResponse,
    JobRunResponse,
    JobUpdate,
    TriggerJobRequest,
    TriggerJobResponse,
)
from src.repositories.job_repo import JobRepository, JobRunRepository
from src.services.job_orchestrator import JobOrchestratorService

router = APIRouter()


@router.get(
    "",
    response_model=PaginatedResponse[JobResponse],
    dependencies=[require_permission("jobs:read")],
)
async def list_jobs(
    session: DBSession,
    page: int = 1,
    page_size: int = 50,
    job_type: str | None = None,
):
    """List all configured jobs."""
    repo = JobRepository(session)
    offset = (page - 1) * page_size
    filters = {"job_type": job_type} if job_type else None
    jobs, total = await repo.get_all(offset=offset, limit=page_size, filters=filters)
    return PaginatedResponse(
        items=[JobResponse.model_validate(j) for j in jobs],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size,
    )


@router.post(
    "",
    response_model=IDResponse,
    dependencies=[require_permission("jobs:write")],
)
async def create_job(data: JobCreate, session: DBSession):
    """Create a new job definition."""
    repo = JobRepository(session)
    job = await repo.create(**data.model_dump())
    return IDResponse(id=job.id, message=f"Job '{data.name}' created")


@router.get(
    "/{job_id}",
    response_model=JobResponse,
    dependencies=[require_permission("jobs:read")],
)
async def get_job(job_id: UUID, session: DBSession):
    """Get job details."""
    repo = JobRepository(session)
    job = await repo.get_by_id(job_id)
    if job is None:
        from src.core.exceptions import NotFoundError
        raise NotFoundError(f"Job {job_id} not found")
    return JobResponse.model_validate(job)


@router.put(
    "/{job_id}",
    response_model=JobResponse,
    dependencies=[require_permission("jobs:write")],
)
async def update_job(job_id: UUID, data: JobUpdate, session: DBSession):
    """Update a job definition."""
    repo = JobRepository(session)
    job = await repo.update(job_id, **data.model_dump(exclude_unset=True))
    if job is None:
        from src.core.exceptions import NotFoundError
        raise NotFoundError(f"Job {job_id} not found")
    return JobResponse.model_validate(job)


@router.delete(
    "/{job_id}",
    response_model=StatusResponse,
    dependencies=[require_permission("jobs:delete")],
)
async def delete_job(job_id: UUID, session: DBSession):
    """Delete a job definition."""
    repo = JobRepository(session)
    if not await repo.delete(job_id):
        from src.core.exceptions import NotFoundError
        raise NotFoundError(f"Job {job_id} not found")
    return StatusResponse(status="deleted", message=f"Job {job_id} deleted")


@router.post(
    "/trigger",
    response_model=TriggerJobResponse,
    dependencies=[require_permission("jobs:execute")],
)
async def trigger_job(
    data: TriggerJobRequest,
    current_user: CurrentUser,
    session: DBSession,
):
    """Trigger a job for immediate execution."""
    orchestrator = JobOrchestratorService(session)
    result = await orchestrator.trigger_job(
        job_id=data.job_id,
        triggered_by="api",
        params=data.params,
        user_id=current_user["user_id"],
    )
    return TriggerJobResponse(
        job_run_id=UUID(result["job_run_id"]),
        status=result["status"],
        message=result["message"],
    )


@router.get(
    "/{job_id}/runs",
    response_model=list[JobRunResponse],
    dependencies=[require_permission("jobs:read")],
)
async def list_job_runs(job_id: UUID, session: DBSession, limit: int = 20):
    """List recent runs for a job."""
    repo = JobRunRepository(session)
    runs = await repo.get_runs_for_job(job_id, limit=limit)
    return [JobRunResponse.model_validate(r) for r in runs]


@router.get(
    "/runs/{run_id}/status",
    dependencies=[require_permission("jobs:read")],
)
async def get_run_status(run_id: UUID, session: DBSession):
    """Get detailed status of a job run including steps."""
    orchestrator = JobOrchestratorService(session)
    return await orchestrator.get_run_status(run_id)
