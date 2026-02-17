"""Admin dashboard backend API endpoints."""

from typing import Any
from uuid import UUID

from fastapi import APIRouter

from src.api.deps import DBSession, require_permission
from src.repositories.job_repo import JobRunRepository
from src.services.audit_service import AuditService
from src.services.sla_service import SLAService

router = APIRouter()


@router.get(
    "/dashboard",
    dependencies=[require_permission("admin:all")],
)
async def admin_dashboard(session: DBSession) -> dict[str, Any]:
    """Admin dashboard summary: jobs, SLA, errors."""
    run_repo = JobRunRepository(session)
    sla_service = SLAService(session)
    audit_service = AuditService(session)

    # Job stats
    job_stats = await run_repo.count_by_status_last_24h()
    active_runs = await run_repo.get_active_runs()

    # SLA compliance
    sla_summary = await sla_service.get_compliance_summary()

    # Recent errors
    unresolved_errors = await audit_service.get_unresolved_errors(limit=10)

    return {
        "jobs": {
            "active_runs": len(active_runs),
            "stats_24h": job_stats,
        },
        "sla": sla_summary,
        "errors": {
            "unresolved_count": len(unresolved_errors),
            "recent": [
                {
                    "id": str(e.id),
                    "error_code": e.error_code,
                    "severity": e.severity,
                    "message": e.message[:200],
                    "timestamp": e.timestamp.isoformat(),
                }
                for e in unresolved_errors
            ],
        },
    }


@router.get(
    "/audit",
    dependencies=[require_permission("audit:read")],
)
async def get_audit_trail(
    session: DBSession,
    limit: int = 100,
    action: str | None = None,
    resource_type: str | None = None,
):
    """Get the audit trail."""
    service = AuditService(session)
    logs = await service.get_audit_trail(
        limit=limit,
        action_filter=action,
        resource_type_filter=resource_type,
    )
    return [
        {
            "id": str(log.id),
            "timestamp": log.timestamp.isoformat(),
            "username": log.username,
            "action": log.action,
            "resource_type": log.resource_type,
            "resource_id": log.resource_id,
            "details": log.details,
            "ip_address": log.ip_address,
        }
        for log in logs
    ]


@router.get(
    "/errors",
    dependencies=[require_permission("audit:read")],
)
async def get_errors(session: DBSession, limit: int = 50):
    """Get unresolved errors."""
    service = AuditService(session)
    errors = await service.get_unresolved_errors(limit=limit)
    return [
        {
            "id": str(e.id),
            "timestamp": e.timestamp.isoformat(),
            "error_code": e.error_code,
            "severity": e.severity,
            "source_service": e.source_service,
            "message": e.message,
            "job_run_id": str(e.job_run_id) if e.job_run_id else None,
            "resolved": e.resolved,
        }
        for e in errors
    ]


@router.post(
    "/errors/{error_id}/resolve",
    dependencies=[require_permission("admin:all")],
)
async def resolve_error(error_id: UUID, session: DBSession):
    """Mark an error as resolved."""
    service = AuditService(session)
    error = await service.resolve_error(error_id, resolved_by="admin")
    if error is None:
        from src.core.exceptions import NotFoundError

        raise NotFoundError(f"Error {error_id} not found")
    return {"status": "resolved", "error_id": str(error_id)}


@router.get(
    "/sla/breaches",
    dependencies=[require_permission("audit:read")],
)
async def get_sla_breaches(
    session: DBSession,
    limit: int = 50,
    job_type: str | None = None,
):
    """Get SLA breach history."""
    service = SLAService(session)
    breaches = await service.get_breaches(limit=limit, job_type=job_type)
    return [
        {
            "id": str(b.id),
            "job_run_id": str(b.job_run_id),
            "expected_minutes": b.expected_duration_minutes,
            "actual_minutes": float(b.actual_duration_minutes) if b.actual_duration_minutes else None,
            "breach_reason": b.breach_reason,
            "evaluated_at": b.evaluated_at.isoformat(),
        }
        for b in breaches
    ]
