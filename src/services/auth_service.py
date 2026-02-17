"""Authentication service: login, token management, user CRUD."""

from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.config.settings import get_settings
from src.core.exceptions import AuthenticationError, ConflictError, NotFoundError
from src.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from src.models.schemas.auth import LoginRequest, TokenResponse, UserCreate, UserResponse
from src.repositories.user_repo import UserRepository

logger = get_logger(__name__)


class AuthService:
    def __init__(self, session: AsyncSession):
        self.repo = UserRepository(session)
        self.session = session

    async def login(self, request: LoginRequest) -> TokenResponse:
        user = await self.repo.get_by_username(request.username)
        if user is None or not verify_password(request.password, user.hashed_password):
            raise AuthenticationError("Invalid username or password")

        if not user.is_active:
            raise AuthenticationError("Account is disabled")

        # Update last login
        user.last_login = datetime.now(timezone.utc)
        await self.session.flush()

        settings = get_settings()
        access_token = create_access_token(str(user.id), user.role)
        refresh_token = create_refresh_token(str(user.id))

        logger.info("user_login", username=user.username, role=user.role)

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.jwt_access_token_expire_minutes * 60,
        )

    async def refresh_tokens(self, refresh_token: str) -> TokenResponse:
        payload = decode_token(refresh_token)
        if payload.get("type") != "refresh":
            raise AuthenticationError("Invalid token type")

        user = await self.repo.get_by_id(UUID(payload["sub"]))
        if user is None or not user.is_active:
            raise AuthenticationError("User not found or disabled")

        settings = get_settings()
        new_access = create_access_token(str(user.id), user.role)
        new_refresh = create_refresh_token(str(user.id))

        return TokenResponse(
            access_token=new_access,
            refresh_token=new_refresh,
            expires_in=settings.jwt_access_token_expire_minutes * 60,
        )

    async def create_user(self, data: UserCreate) -> UserResponse:
        existing = await self.repo.get_by_username(data.username)
        if existing:
            raise ConflictError(f"Username '{data.username}' already exists")

        existing_email = await self.repo.get_by_email(data.email)
        if existing_email:
            raise ConflictError(f"Email '{data.email}' already registered")

        user = await self.repo.create(
            username=data.username,
            email=data.email,
            hashed_password=hash_password(data.password),
            full_name=data.full_name,
            role=data.role,
        )

        logger.info("user_created", username=user.username, role=user.role)
        return UserResponse.model_validate(user)

    async def get_user(self, user_id: UUID) -> UserResponse:
        user = await self.repo.get_by_id(user_id)
        if user is None:
            raise NotFoundError(f"User {user_id} not found")
        return UserResponse.model_validate(user)

    async def list_users(
        self, offset: int = 0, limit: int = 50
    ) -> tuple[list[UserResponse], int]:
        users, total = await self.repo.get_all(offset=offset, limit=limit)
        return [UserResponse.model_validate(u) for u in users], total
