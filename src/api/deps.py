"""
FastAPI dependency injection: database sessions, authentication, RBAC.
"""

from typing import Annotated
from uuid import UUID

from fastapi import Depends, Header, Request
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.exceptions import AuthenticationError, AuthorizationError
from src.core.security import check_permission, decode_token
from src.db.postgres import get_db_session


# Type alias for DB session dependency
DBSession = Annotated[AsyncSession, Depends(get_db_session)]


async def get_current_user(
    authorization: str = Header(..., description="Bearer <token>"),
) -> dict:
    """Extract and validate the current user from JWT bearer token."""
    if not authorization.startswith("Bearer "):
        raise AuthenticationError("Invalid authorization header format")

    token = authorization[7:]
    payload = decode_token(token)

    return {
        "user_id": UUID(payload["sub"]),
        "role": payload["role"],
    }


CurrentUser = Annotated[dict, Depends(get_current_user)]


def require_permission(permission: str):
    """Dependency factory for RBAC permission checks."""

    async def _check(current_user: CurrentUser) -> dict:
        check_permission(current_user["role"], permission)
        return current_user

    return Depends(_check)


def get_client_ip(request: Request) -> str:
    """Extract client IP from request (supports proxied requests)."""
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"
