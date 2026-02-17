"""
Platform-wide exception hierarchy.
Structured exceptions that map to HTTP status codes without leaking internals.
"""

from typing import Any


class PlatformError(Exception):
    """Base exception for all platform errors."""

    status_code: int = 500
    error_code: str = "PLATFORM_ERROR"

    def __init__(self, message: str, details: dict[str, Any] | None = None):
        self.message = message
        self.details = details or {}
        super().__init__(self.message)

    def to_dict(self) -> dict[str, Any]:
        return {
            "error_code": self.error_code,
            "message": self.message,
            "details": self.details,
        }


# --- Authentication / Authorization ---
class AuthenticationError(PlatformError):
    status_code = 401
    error_code = "AUTHENTICATION_FAILED"


class AuthorizationError(PlatformError):
    status_code = 403
    error_code = "INSUFFICIENT_PERMISSIONS"


class TokenExpiredError(AuthenticationError):
    error_code = "TOKEN_EXPIRED"


# --- Resource Errors ---
class NotFoundError(PlatformError):
    status_code = 404
    error_code = "RESOURCE_NOT_FOUND"


class ConflictError(PlatformError):
    status_code = 409
    error_code = "RESOURCE_CONFLICT"


class ValidationError(PlatformError):
    status_code = 422
    error_code = "VALIDATION_ERROR"


# --- Database Errors ---
class DatabaseError(PlatformError):
    status_code = 503
    error_code = "DATABASE_ERROR"


class OracleConnectionError(DatabaseError):
    error_code = "ORACLE_CONNECTION_FAILED"


class PostgresConnectionError(DatabaseError):
    error_code = "POSTGRES_CONNECTION_FAILED"


# --- Job Errors ---
class JobError(PlatformError):
    status_code = 500
    error_code = "JOB_ERROR"


class JobTimeoutError(JobError):
    error_code = "JOB_TIMEOUT"


class JobAlreadyRunningError(JobError):
    status_code = 409
    error_code = "JOB_ALREADY_RUNNING"


class DependencyError(JobError):
    error_code = "DEPENDENCY_RESOLUTION_FAILED"


# --- ETL Errors ---
class ExportError(PlatformError):
    error_code = "EXPORT_FAILED"


class LoadError(PlatformError):
    error_code = "LOAD_FAILED"


class RefreshError(PlatformError):
    error_code = "REFRESH_FAILED"


# --- SLA ---
class SLABreachError(PlatformError):
    status_code = 500
    error_code = "SLA_BREACH"


# --- External Service ---
class ExternalServiceError(PlatformError):
    status_code = 502
    error_code = "EXTERNAL_SERVICE_ERROR"
