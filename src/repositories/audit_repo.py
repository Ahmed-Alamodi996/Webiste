"""Audit and error log repository."""

from datetime import datetime, timezone
from typing import Any, Sequence
from uuid import UUID

from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.domain.audit import AuditLog, ErrorLog
from src.repositories.base import BaseRepository


class AuditLogRepository(BaseRepository[AuditLog]):
    def __init__(self, session: AsyncSession):
        super().__init__(AuditLog, session)

    async def log_action(
        self,
        action: str,
        user_id: UUID | None = None,
        username: str | None = None,
        resource_type: str | None = None,
        resource_id: str | None = None,
        details: dict[str, Any] | None = None,
        ip_address: str | None = None,
        user_agent: str | None = None,
    ) -> AuditLog:
        return await self.create(
            action=action,
            user_id=user_id,
            username=username,
            resource_type=resource_type,
            resource_id=resource_id,
            details=details or {},
            ip_address=ip_address,
            user_agent=user_agent,
        )

    async def get_recent(
        self,
        limit: int = 100,
        action_filter: str | None = None,
        resource_type_filter: str | None = None,
    ) -> Sequence[AuditLog]:
        query = select(AuditLog).order_by(desc(AuditLog.timestamp))
        if action_filter:
            query = query.where(AuditLog.action == action_filter)
        if resource_type_filter:
            query = query.where(AuditLog.resource_type == resource_type_filter)
        result = await self.session.execute(query.limit(limit))
        return result.scalars().all()


class ErrorLogRepository(BaseRepository[ErrorLog]):
    def __init__(self, session: AsyncSession):
        super().__init__(ErrorLog, session)

    async def log_error(
        self,
        error_code: str,
        source_service: str,
        message: str,
        severity: str = "error",
        job_run_id: UUID | None = None,
        stack_trace: str | None = None,
        context: dict[str, Any] | None = None,
    ) -> ErrorLog:
        return await self.create(
            error_code=error_code,
            severity=severity,
            source_service=source_service,
            job_run_id=job_run_id,
            message=message,
            stack_trace=stack_trace,
            context=context or {},
        )

    async def get_unresolved(self, limit: int = 100) -> Sequence[ErrorLog]:
        result = await self.session.execute(
            select(ErrorLog)
            .where(ErrorLog.resolved.is_(False))
            .order_by(desc(ErrorLog.timestamp))
            .limit(limit)
        )
        return result.scalars().all()

    async def resolve_error(
        self, error_id: UUID, resolved_by: str
    ) -> ErrorLog | None:
        return await self.update(
            error_id,
            resolved=True,
            resolved_by=resolved_by,
            resolved_at=datetime.now(timezone.utc),
        )
