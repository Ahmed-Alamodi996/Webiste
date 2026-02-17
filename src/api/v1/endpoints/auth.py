"""Authentication endpoints: login, refresh, user management."""

from fastapi import APIRouter

from src.api.deps import CurrentUser, DBSession, require_permission
from src.models.schemas.auth import (
    LoginRequest,
    RefreshTokenRequest,
    TokenResponse,
    UserCreate,
    UserResponse,
)
from src.models.schemas.common import PaginatedResponse
from src.services.auth_service import AuthService

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest, session: DBSession):
    """Authenticate user and return JWT tokens."""
    service = AuthService(session)
    return await service.login(request)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(request: RefreshTokenRequest, session: DBSession):
    """Refresh an expired access token."""
    service = AuthService(session)
    return await service.refresh_tokens(request.refresh_token)


@router.post(
    "/users",
    response_model=UserResponse,
    dependencies=[require_permission("users:write")],
)
async def create_user(data: UserCreate, session: DBSession):
    """Create a new user (admin only)."""
    service = AuthService(session)
    return await service.create_user(data)


@router.get(
    "/users",
    response_model=PaginatedResponse[UserResponse],
    dependencies=[require_permission("users:read")],
)
async def list_users(
    session: DBSession,
    page: int = 1,
    page_size: int = 50,
):
    """List all users."""
    service = AuthService(session)
    offset = (page - 1) * page_size
    users, total = await service.list_users(offset=offset, limit=page_size)
    return PaginatedResponse(
        items=users,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size,
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: CurrentUser, session: DBSession):
    """Get current authenticated user's profile."""
    service = AuthService(session)
    return await service.get_user(current_user["user_id"])
