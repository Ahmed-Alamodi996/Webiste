"""MV Refresh and Dependency Scan job worker handler."""

from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.services.dependency_engine import DependencyEngineService
from src.services.mv_refresh import MVRefreshService

logger = get_logger(__name__)


async def handle_refresh_job(
    payload: dict[str, Any], session: AsyncSession
) -> dict[str, Any]:
    """
    Handle a refresh or dependency_scan job:
    - For dependency_scan: scan Oracle metadata, build graph, compute refresh plan
    - For refresh: execute MV refresh in dependency order
    """
    job_type = payload.get("job_type", "refresh")
    config = payload.get("config", {})
    params = payload.get("params", {})

    schema_owner = config.get("schema_owner", "RECON_PRD")
    refresh_type = config.get("refresh_type", "COMPLETE")
    max_parallel = config.get("max_parallel", 4)
    timeout_per_mv = config.get("timeout_per_mv", 3600)

    if job_type == "dependency_scan":
        # Just scan and store the graph
        engine = DependencyEngineService()
        result = await engine.scan_dependencies(schema_owner=schema_owner)

        return {
            "records_processed": result["total_objects"],
            "total_edges": result["total_edges"],
            "levels": result["topological_levels"],
            "scan_id": result["scan_id"],
        }

    # Full refresh: scan dependencies first, then refresh in order
    engine = DependencyEngineService()
    scan_result = await engine.scan_dependencies(schema_owner=schema_owner)
    refresh_plan = engine.get_refresh_plan(
        scan_result["sorted_order"], scan_result["levels"]
    )

    logger.info(
        "refresh_plan_generated",
        levels=len(refresh_plan),
        total_mvs=sum(len(level) for level in refresh_plan),
    )

    # Filter to specific MVs if provided in params
    target_mvs = params.get("target_mvs")
    if target_mvs:
        refresh_plan = [
            [mv for mv in level if mv in target_mvs]
            for level in refresh_plan
        ]
        refresh_plan = [level for level in refresh_plan if level]

    # Execute refresh
    refresh_service = MVRefreshService()
    result = await refresh_service.refresh_all(
        refresh_plan=refresh_plan,
        refresh_type=refresh_type,
        max_parallel=max_parallel,
        timeout_per_mv=timeout_per_mv,
    )

    return {
        "records_processed": result["success"],
        "records_failed": result["failed"],
        "total_mvs": result["total_mvs"],
        "total_levels": result["total_levels"],
        "duration_seconds": result["duration_seconds"],
    }
