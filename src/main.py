"""
Revenue Assurance Data Automation Platform
Main FastAPI application entry point.

This is a production-grade, enterprise-scale platform for:
- Oracle table export with chunked reads
- ETL loading (CSV/Excel/PostgreSQL -> Oracle) via SQL*Loader
- Dependency-aware materialized view refresh
- Job orchestration with retry, timeout, and SLA tracking
- Full audit trail and structured logging

Architecture: Microservices-ready, containerized, Kubernetes-deployable
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

from fastapi.staticfiles import StaticFiles

from src.api.v1.router import api_router
from src.config.logging import setup_logging
from src.config.settings import get_settings
from src.core.events import on_shutdown, on_startup
from src.core.middleware import (
    RequestTrackingMiddleware,
    SecurityHeadersMiddleware,
    register_exception_handlers,
)
from src.dashboard.router import router as dashboard_router


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Application lifecycle: startup and shutdown hooks."""
    await on_startup()
    yield
    await on_shutdown()


def create_app() -> FastAPI:
    """Application factory pattern."""
    settings = get_settings()
    setup_logging()

    app = FastAPI(
        title="Revenue Assurance Platform",
        description=(
            "Enterprise-grade data automation platform for revenue assurance operations. "
            "Manages Oracle exports, ETL pipelines, materialized view refresh, "
            "dependency analysis, and job orchestration."
        ),
        version=settings.app_version,
        docs_url="/api/docs" if not settings.is_production else None,
        redoc_url="/api/redoc" if not settings.is_production else None,
        openapi_url="/api/openapi.json" if not settings.is_production else None,
        lifespan=lifespan,
    )

    # --- Middleware (order matters: outermost first) ---
    app.add_middleware(SecurityHeadersMiddleware)
    app.add_middleware(RequestTrackingMiddleware)

    if not settings.is_production:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    # --- Exception Handlers ---
    register_exception_handlers(app)

    # --- Prometheus Metrics ---
    Instrumentator(
        should_group_status_codes=True,
        should_instrument_requests_inprogress=True,
        excluded_handlers=["/api/v1/health", "/metrics"],
        inprogress_name="ra_http_requests_inprogress",
        inprogress_labels=True,
    ).instrument(app).expose(app, endpoint="/metrics/prometheus")

    # --- Routes ---
    app.include_router(api_router)

    # --- Web Dashboard (non-production or when ENABLE_DASHBOARD=true) ---
    if not settings.is_production or getattr(settings, "enable_dashboard", False):
        from pathlib import Path

        static_dir = Path(__file__).parent / "dashboard" / "static"
        if static_dir.exists():
            app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")
        app.include_router(dashboard_router, prefix="/ui", tags=["Dashboard"])

    return app


# Create the application instance
app = create_app()
