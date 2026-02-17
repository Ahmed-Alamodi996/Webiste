"""Authentication and user Pydantic schemas."""

from datetime import datetime
from uuid import UUID

from pydantic import EmailStr, Field

from src.models.schemas.common import BaseSchema


class LoginRequest(BaseSchema):
    username: str = Field(..., min_length=3, max_length=100)
    password: str = Field(..., min_length=8)


class TokenResponse(BaseSchema):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class RefreshTokenRequest(BaseSchema):
    refresh_token: str


class UserCreate(BaseSchema):
    username: str = Field(..., min_length=3, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str = Field(..., min_length=1, max_length=255)
    role: str = Field(default="viewer", pattern="^(admin|operator|viewer)$")


class UserUpdate(BaseSchema):
    email: EmailStr | None = None
    full_name: str | None = None
    role: str | None = Field(default=None, pattern="^(admin|operator|viewer)$")
    is_active: bool | None = None


class UserResponse(BaseSchema):
    id: UUID
    username: str
    email: str
    full_name: str
    role: str
    is_active: bool
    created_at: datetime
    last_login: datetime | None
