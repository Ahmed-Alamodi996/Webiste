"""Health check endpoints for load balancers and monitoring."""

from fastapi import APIRouter

from src.services.health_service import check_health

router = APIRouter()


@router.get("/health")
async def health_check():
    """Liveness probe: is the API server running?"""
    return await check_health()


@router.get("/health/ready")
async def readiness_check():
    """Readiness probe: are all dependencies available?"""
    result = await check_health()
    if result["status"] == "unhealthy":
        from fastapi.responses import JSONResponse

        return JSONResponse(status_code=503, content=result)
    return result
