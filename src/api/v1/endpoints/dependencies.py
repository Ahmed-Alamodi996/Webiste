"""Dependency Graph API endpoints."""

from fastapi import APIRouter

from src.api.deps import DBSession, require_permission
from src.models.schemas.config import DependencyGraphResponse
from src.repositories.config_repo import DependencyGraphRepository
from src.services.dependency_engine import DependencyEngineService

router = APIRouter()


@router.post(
    "/scan",
    dependencies=[require_permission("jobs:execute")],
)
async def scan_dependencies(schema_owner: str = "RECON_PRD"):
    """Trigger a full dependency graph scan of Oracle views/MVs."""
    service = DependencyEngineService()
    result = await service.scan_dependencies(schema_owner=schema_owner)

    # Return the refresh plan (levels for parallel execution)
    refresh_plan = service.get_refresh_plan(
        result["sorted_order"], result["levels"]
    )

    return {
        "scan_id": result["scan_id"],
        "total_objects": result["total_objects"],
        "total_edges": result["total_edges"],
        "topological_levels": result["topological_levels"],
        "refresh_plan": refresh_plan,
        "refresh_plan_summary": [
            {"level": i, "mv_count": len(level)}
            for i, level in enumerate(refresh_plan)
        ],
    }


@router.get(
    "/graph",
    response_model=list[DependencyGraphResponse],
    dependencies=[require_permission("jobs:read")],
)
async def get_dependency_graph(session: DBSession):
    """Get the latest dependency graph from the metadata store."""
    repo = DependencyGraphRepository(session)
    edges = await repo.get_latest_graph()
    return [DependencyGraphResponse.model_validate(e) for e in edges]


@router.post(
    "/refresh-plan",
    dependencies=[require_permission("jobs:read")],
)
async def generate_refresh_plan(schema_owner: str = "RECON_PRD"):
    """Generate an optimized MV refresh plan based on dependency analysis."""
    service = DependencyEngineService()
    result = await service.scan_dependencies(schema_owner=schema_owner)
    refresh_plan = service.get_refresh_plan(
        result["sorted_order"], result["levels"]
    )
    return {
        "total_levels": len(refresh_plan),
        "total_mvs": sum(len(level) for level in refresh_plan),
        "plan": [
            {"level": i, "mvs": mvs, "count": len(mvs)}
            for i, mvs in enumerate(refresh_plan)
        ],
    }
