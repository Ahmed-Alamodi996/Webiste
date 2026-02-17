"""Dashboard web routes - serves HTML pages with HTMX interactivity."""

from pathlib import Path
from typing import Any

from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

TEMPLATE_DIR = Path(__file__).parent / "templates"
templates = Jinja2Templates(directory=str(TEMPLATE_DIR))

router = APIRouter()


def _base_context(request: Request, page: str = "") -> dict[str, Any]:
    return {
        "request": request,
        "current_page": page,
        "nav_items": [
            {"name": "Dashboard", "url": "/ui/", "icon": "bi-speedometer2", "id": "dashboard"},
            {"name": "Jobs", "url": "/ui/jobs", "icon": "bi-play-circle", "id": "jobs"},
            {"name": "Config", "url": "/ui/config", "icon": "bi-gear", "id": "config"},
            {"name": "Logs", "url": "/ui/logs", "icon": "bi-journal-text", "id": "logs"},
            {"name": "Reports", "url": "/ui/reports", "icon": "bi-file-earmark-bar-graph", "id": "reports"},
        ],
    }


@router.get("/", response_class=HTMLResponse)
async def dashboard_page(request: Request):
    """Main dashboard overview page."""
    ctx = _base_context(request, "dashboard")
    return templates.TemplateResponse("dashboard.html", ctx)


@router.get("/jobs", response_class=HTMLResponse)
async def jobs_page(request: Request):
    """Jobs management page."""
    ctx = _base_context(request, "jobs")
    return templates.TemplateResponse("jobs.html", ctx)


@router.get("/config", response_class=HTMLResponse)
async def config_page(request: Request):
    """Configuration management page."""
    ctx = _base_context(request, "config")
    return templates.TemplateResponse("config.html", ctx)


@router.get("/logs", response_class=HTMLResponse)
async def logs_page(request: Request):
    """Logs and audit trail page."""
    ctx = _base_context(request, "logs")
    return templates.TemplateResponse("logs.html", ctx)


@router.get("/reports", response_class=HTMLResponse)
async def reports_page(request: Request):
    """Report generation page."""
    ctx = _base_context(request, "reports")
    return templates.TemplateResponse("reports.html", ctx)
