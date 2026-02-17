"""Report generation API endpoints."""

from fastapi import APIRouter
from fastapi.responses import Response

from src.api.deps import DBSession, require_permission
from src.repositories.job_repo import JobRepository, JobRunRepository
from src.services.audit_service import AuditService
from src.services.report_service import ReportService
from src.services.sla_service import SLAService

router = APIRouter()
report_service = ReportService()


CONTENT_TYPES = {
    "html": "text/html",
    "csv": "text/csv",
    "json": "application/json",
}


@router.get(
    "/jobs",
    dependencies=[require_permission("jobs:read")],
)
async def report_jobs(
    session: DBSession,
    format: str = "html",
    job_type: str | None = None,
):
    """Generate a job report (HTML, CSV, or JSON)."""
    repo = JobRepository(session)
    filters = {"job_type": job_type} if job_type else None
    jobs, _ = await repo.get_all(offset=0, limit=1000, filters=filters)
    data = [_to_dict(j) for j in jobs]

    content = report_service.generate_report(data, "jobs", format)
    return Response(
        content=content,
        media_type=CONTENT_TYPES.get(format, "text/html"),
        headers={"Content-Disposition": f'inline; filename="report_jobs.{format}"'},
    )


@router.get(
    "/errors",
    dependencies=[require_permission("audit:read")],
)
async def report_errors(
    session: DBSession,
    format: str = "html",
    limit: int = 200,
):
    """Generate an error report."""
    service = AuditService(session)
    errors = await service.get_unresolved_errors(limit=limit)
    data = [_to_dict(e) for e in errors]

    content = report_service.generate_report(data, "errors", format)
    return Response(
        content=content,
        media_type=CONTENT_TYPES.get(format, "text/html"),
        headers={"Content-Disposition": f'inline; filename="report_errors.{format}"'},
    )


@router.get(
    "/audit",
    dependencies=[require_permission("audit:read")],
)
async def report_audit(
    session: DBSession,
    format: str = "html",
    limit: int = 500,
):
    """Generate an audit trail report."""
    service = AuditService(session)
    logs = await service.get_audit_trail(limit=limit)
    data = [_to_dict(log) for log in logs]

    content = report_service.generate_report(data, "audit", format)
    return Response(
        content=content,
        media_type=CONTENT_TYPES.get(format, "text/html"),
        headers={"Content-Disposition": f'inline; filename="report_audit.{format}"'},
    )


@router.get(
    "/sla",
    dependencies=[require_permission("audit:read")],
)
async def report_sla(
    session: DBSession,
    format: str = "html",
    limit: int = 200,
):
    """Generate an SLA compliance report."""
    service = SLAService(session)
    breaches = await service.get_breaches(limit=limit)
    data = [_to_dict(b) for b in breaches]

    content = report_service.generate_report(data, "sla_breaches", format)
    return Response(
        content=content,
        media_type=CONTENT_TYPES.get(format, "text/html"),
        headers={"Content-Disposition": f'inline; filename="report_sla.{format}"'},
    )


def _to_dict(obj) -> dict:
    """Convert an ORM model to a dict, handling common patterns."""
    if hasattr(obj, "__dict__"):
        d = {}
        for k, v in obj.__dict__.items():
            if not k.startswith("_"):
                d[k] = str(v) if hasattr(v, "isoformat") else v
        return d
    return dict(obj)
