"""
Central API v1 router. Aggregates all endpoint modules.
"""

from fastapi import APIRouter

from src.api.v1.endpoints import (
    admin,
    auth,
    config,
    dependencies,
    export,
    health,
    jobs,
    loader,
    metrics,
    refresh,
)

api_router = APIRouter(prefix="/api/v1")

# Public endpoints (no auth)
api_router.include_router(health.router, tags=["Health"])
api_router.include_router(metrics.router, tags=["Metrics"])
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])

# Protected endpoints
api_router.include_router(jobs.router, prefix="/jobs", tags=["Jobs"])
api_router.include_router(config.router, prefix="/config", tags=["Configuration"])
api_router.include_router(export.router, prefix="/export", tags=["Oracle Export"])
api_router.include_router(loader.router, prefix="/loader", tags=["ETL Loader"])
api_router.include_router(refresh.router, prefix="/refresh", tags=["MV Refresh"])
api_router.include_router(dependencies.router, prefix="/dependencies", tags=["Dependency Graph"])
api_router.include_router(admin.router, prefix="/admin", tags=["Administration"])
