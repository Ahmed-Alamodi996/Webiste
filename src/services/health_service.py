"""Health and metrics service for observability endpoints."""

import time
from typing import Any

from src.config.logging import get_logger
from src.config.settings import get_settings
from src.db.oracle import OraclePool
from src.db.postgres import async_engine
from src.db.redis import RedisPool

logger = get_logger(__name__)

# Track application start time
_start_time = time.monotonic()


async def check_health() -> dict[str, Any]:
    """
    Comprehensive health check for all platform dependencies.
    Returns overall status + per-component status.
    """
    settings = get_settings()
    checks: dict[str, str] = {}

    # PostgreSQL
    try:
        async with async_engine.connect() as conn:
            await conn.execute("SELECT 1")
        checks["postgres"] = "healthy"
    except Exception as e:
        checks["postgres"] = f"unhealthy: {str(e)[:100]}"

    # Redis
    try:
        client = RedisPool.get_client()
        await client.ping()
        checks["redis"] = "healthy"
    except Exception as e:
        checks["redis"] = f"unhealthy: {str(e)[:100]}"

    # Oracle
    try:
        stats = OraclePool.pool_stats()
        checks["oracle"] = f"healthy (busy={stats['busy']}, open={stats['open']})"
    except Exception as e:
        checks["oracle"] = f"unhealthy: {str(e)[:100]}"

    # Determine overall status
    unhealthy = [k for k, v in checks.items() if "unhealthy" in v]
    if not unhealthy:
        status = "healthy"
    elif len(unhealthy) == len(checks):
        status = "unhealthy"
    else:
        status = "degraded"

    uptime = time.monotonic() - _start_time

    return {
        "status": status,
        "version": settings.app_version,
        "environment": settings.environment,
        "uptime_seconds": round(uptime, 2),
        "checks": checks,
    }


async def get_metrics() -> dict[str, Any]:
    """Get platform metrics for monitoring dashboards."""
    settings = get_settings()

    # Oracle pool stats
    try:
        oracle_stats = OraclePool.pool_stats()
    except Exception:
        oracle_stats = {"busy": 0, "open": 0, "min": 0, "max": 0}

    # Redis connectivity
    try:
        client = RedisPool.get_client()
        await client.ping()
        redis_connected = True
    except Exception:
        redis_connected = False

    # Postgres connectivity
    try:
        async with async_engine.connect() as conn:
            await conn.execute("SELECT 1")
        pg_connected = True
    except Exception:
        pg_connected = False

    return {
        "oracle_pool_busy": oracle_stats.get("busy", 0),
        "oracle_pool_open": oracle_stats.get("open", 0),
        "redis_connected": redis_connected,
        "postgres_connected": pg_connected,
        "uptime_seconds": round(time.monotonic() - _start_time, 2),
    }
