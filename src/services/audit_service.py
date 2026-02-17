"""Audit & Logging Service: centralized audit trail and error management."""

from typing import Any, Sequence
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.models.domain.audit import AuditLog, ErrorLog
from src.repositories.audit_repo import AuditLogRepository, ErrorLogRepository

logger = get_logger(__name__)


class AuditService:
    def __init__(self, session: AsyncSession):
        self.audit_repo = AuditLogRepository(session)
        self.error_repo = ErrorLogRepository(session)

    async def record_action(
        self,
        action: str,
        user_id: UUID | None = None,
        username: str | None = None,
        resource_type: str | None = None,
        resource_id: str | None = None,
        details: dict[str, Any] | None = None,
        ip_address: str | None = None,
    ) -> AuditLog:
        return await self.audit_repo.log_action(
            action=action,
            user_id=user_id,
            username=username,
            resource_type=resource_type,
            resource_id=resource_id,
            details=details,
            ip_address=ip_address,
        )

    async def get_audit_trail(
        self,
        limit: int = 100,
        action_filter: str | None = None,
        resource_type_filter: str | None = None,
    ) -> Sequence[AuditLog]:
        return await self.audit_repo.get_recent(
            limit=limit,
            action_filter=action_filter,
            resource_type_filter=resource_type_filter,
        )

    async def record_error(
        self,
        error_code: str,
        source_service: str,
        message: str,
        severity: str = "error",
        job_run_id: UUID | None = None,
        stack_trace: str | None = None,
        context: dict[str, Any] | None = None,
    ) -> ErrorLog:
        return await self.error_repo.log_error(
            error_code=error_code,
            source_service=source_service,
            message=message,
            severity=severity,
            job_run_id=job_run_id,
            stack_trace=stack_trace,
            context=context,
        )

    async def get_unresolved_errors(self, limit: int = 100) -> Sequence[ErrorLog]:
        return await self.error_repo.get_unresolved(limit=limit)

    async def resolve_error(
        self, error_id: UUID, resolved_by: str
    ) -> ErrorLog | None:
        return await self.error_repo.resolve_error(error_id, resolved_by)
