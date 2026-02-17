"""
JWT authentication and RBAC (Role-Based Access Control).
Supports Admin / Operator / Viewer roles.
"""

from datetime import datetime, timedelta, timezone
from enum import Enum
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from src.config.settings import get_settings
from src.core.exceptions import AuthenticationError, AuthorizationError, TokenExpiredError

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class Role(str, Enum):
    ADMIN = "admin"
    OPERATOR = "operator"
    VIEWER = "viewer"


# Permission matrix: role -> allowed actions
ROLE_PERMISSIONS: dict[Role, set[str]] = {
    Role.ADMIN: {
        "jobs:read", "jobs:write", "jobs:execute", "jobs:delete",
        "config:read", "config:write", "config:delete",
        "users:read", "users:write", "users:delete",
        "audit:read",
        "export:execute", "loader:execute", "refresh:execute",
        "admin:all",
    },
    Role.OPERATOR: {
        "jobs:read", "jobs:write", "jobs:execute",
        "config:read", "config:write",
        "audit:read",
        "export:execute", "loader:execute", "refresh:execute",
    },
    Role.VIEWER: {
        "jobs:read",
        "config:read",
        "audit:read",
    },
}


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(
    subject: str,
    role: str,
    additional_claims: dict[str, Any] | None = None,
) -> str:
    settings = get_settings()
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.jwt_access_token_expire_minutes
    )
    payload = {
        "sub": subject,
        "role": role,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "access",
    }
    if additional_claims:
        payload.update(additional_claims)
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_refresh_token(subject: str) -> str:
    settings = get_settings()
    expire = datetime.now(timezone.utc) + timedelta(
        days=settings.jwt_refresh_token_expire_days
    )
    payload = {
        "sub": subject,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "refresh",
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def decode_token(token: str) -> dict[str, Any]:
    settings = get_settings()
    try:
        payload = jwt.decode(
            token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm]
        )
        if payload.get("type") not in ("access", "refresh"):
            raise AuthenticationError("Invalid token type")
        return payload
    except JWTError as e:
        error_str = str(e).lower()
        if "expired" in error_str:
            raise TokenExpiredError("Token has expired")
        raise AuthenticationError("Invalid authentication token")


def check_permission(role: str, permission: str) -> None:
    """Raise AuthorizationError if role lacks the required permission."""
    try:
        user_role = Role(role)
    except ValueError:
        raise AuthorizationError(f"Unknown role: {role}")

    allowed = ROLE_PERMISSIONS.get(user_role, set())
    if permission not in allowed and "admin:all" not in allowed:
        raise AuthorizationError(
            f"Role '{role}' does not have permission '{permission}'"
        )
