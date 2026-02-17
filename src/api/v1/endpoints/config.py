"""Configuration management endpoints: table configs, connection profiles."""

from uuid import UUID

from fastapi import APIRouter

from src.api.deps import DBSession, require_permission
from src.models.schemas.common import IDResponse, PaginatedResponse, StatusResponse
from src.models.schemas.config import (
    ConnectionProfileCreate,
    ConnectionProfileResponse,
    TableConfigCreate,
    TableConfigResponse,
    TableConfigUpdate,
)
from src.services.metadata_service import MetadataService

router = APIRouter()


# --- Table Configuration ---
@router.get(
    "/tables",
    response_model=PaginatedResponse[TableConfigResponse],
    dependencies=[require_permission("config:read")],
)
async def list_table_configs(
    session: DBSession,
    page: int = 1,
    page_size: int = 50,
    source_type: str | None = None,
):
    """List all ETL table configurations (replaces data_mapping.xlsx)."""
    service = MetadataService(session)
    offset = (page - 1) * page_size
    configs, total = await service.list_table_configs(
        offset=offset, limit=page_size, source_type=source_type
    )
    return PaginatedResponse(
        items=[TableConfigResponse.model_validate(c) for c in configs],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size,
    )


@router.post(
    "/tables",
    response_model=IDResponse,
    dependencies=[require_permission("config:write")],
)
async def create_table_config(data: TableConfigCreate, session: DBSession):
    """Create a new table configuration."""
    service = MetadataService(session)
    config = await service.create_table_config(**data.model_dump())
    return IDResponse(id=config.id, message=f"Table config '{data.name}' created")


@router.get(
    "/tables/{config_id}",
    response_model=TableConfigResponse,
    dependencies=[require_permission("config:read")],
)
async def get_table_config(config_id: UUID, session: DBSession):
    """Get a specific table configuration."""
    service = MetadataService(session)
    config = await service.get_table_config(config_id)
    return TableConfigResponse.model_validate(config)


@router.put(
    "/tables/{config_id}",
    response_model=TableConfigResponse,
    dependencies=[require_permission("config:write")],
)
async def update_table_config(
    config_id: UUID, data: TableConfigUpdate, session: DBSession
):
    """Update a table configuration."""
    service = MetadataService(session)
    config = await service.update_table_config(
        config_id, **data.model_dump(exclude_unset=True)
    )
    return TableConfigResponse.model_validate(config)


@router.delete(
    "/tables/{config_id}",
    response_model=StatusResponse,
    dependencies=[require_permission("config:delete")],
)
async def delete_table_config(config_id: UUID, session: DBSession):
    """Delete a table configuration."""
    service = MetadataService(session)
    await service.delete_table_config(config_id)
    return StatusResponse(status="deleted", message=f"Config {config_id} deleted")


# --- Connection Profiles ---
@router.get(
    "/connections",
    response_model=PaginatedResponse[ConnectionProfileResponse],
    dependencies=[require_permission("config:read")],
)
async def list_connections(session: DBSession, page: int = 1, page_size: int = 50):
    """List all database connection profiles."""
    service = MetadataService(session)
    offset = (page - 1) * page_size
    profiles, total = await service.list_connection_profiles(
        offset=offset, limit=page_size
    )
    return PaginatedResponse(
        items=[ConnectionProfileResponse.model_validate(p) for p in profiles],
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size,
    )


@router.post(
    "/connections",
    response_model=IDResponse,
    dependencies=[require_permission("config:write")],
)
async def create_connection(data: ConnectionProfileCreate, session: DBSession):
    """Create a new connection profile (password stored as env var reference)."""
    service = MetadataService(session)
    profile = await service.create_connection_profile(**data.model_dump())
    return IDResponse(id=profile.id, message=f"Connection '{data.name}' created")
