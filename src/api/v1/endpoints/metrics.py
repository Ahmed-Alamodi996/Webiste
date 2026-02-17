"""Metrics endpoint for observability."""

from datetime import datetime, timezone

from fastapi import APIRouter

from src.services.health_service import get_metrics

router = APIRouter()


@router.get("/metrics")
async def platform_metrics():
    """Platform metrics for dashboards and monitoring."""
    data = await get_metrics()
    data["timestamp"] = datetime.now(timezone.utc).isoformat()
    return data
