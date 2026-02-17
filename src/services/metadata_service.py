"""Metadata Service: manages table configs, connection profiles, and data quality rules."""

from typing import Any, Sequence
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.core.exceptions import ConflictError, NotFoundError
from src.models.domain.config import ConnectionProfile, DataQualityRule, TableConfig
from src.repositories.config_repo import (
    ConnectionProfileRepository,
    DataQualityRuleRepository,
    TableConfigRepository,
)

logger = get_logger(__name__)


class MetadataService:
    def __init__(self, session: AsyncSession):
        self.table_repo = TableConfigRepository(session)
        self.conn_repo = ConnectionProfileRepository(session)
        self.dq_repo = DataQualityRuleRepository(session)

    # --- Table Config ---
    async def create_table_config(self, **kwargs: Any) -> TableConfig:
        config = await self.table_repo.create(**kwargs)
        logger.info("table_config_created", name=config.name, id=str(config.id))
        return config

    async def get_table_config(self, config_id: UUID) -> TableConfig:
        config = await self.table_repo.get_by_id(config_id)
        if config is None:
            raise NotFoundError(f"Table config {config_id} not found")
        return config

    async def list_table_configs(
        self, offset: int = 0, limit: int = 100, source_type: str | None = None
    ) -> tuple[Sequence[TableConfig], int]:
        filters = {}
        if source_type:
            filters["source_type"] = source_type
        return await self.table_repo.get_all(
            offset=offset, limit=limit, filters=filters
        )

    async def update_table_config(
        self, config_id: UUID, **kwargs: Any
    ) -> TableConfig:
        config = await self.table_repo.update(config_id, **kwargs)
        if config is None:
            raise NotFoundError(f"Table config {config_id} not found")
        logger.info("table_config_updated", id=str(config_id))
        return config

    async def delete_table_config(self, config_id: UUID) -> None:
        if not await self.table_repo.delete(config_id):
            raise NotFoundError(f"Table config {config_id} not found")
        logger.info("table_config_deleted", id=str(config_id))

    async def get_configs_for_today(self, day: int) -> Sequence[TableConfig]:
        return await self.table_repo.get_by_schedule_day(day)

    # --- Connection Profiles ---
    async def create_connection_profile(self, **kwargs: Any) -> ConnectionProfile:
        existing = await self.conn_repo.get_by_name(kwargs.get("name", ""))
        if existing:
            raise ConflictError(f"Connection profile '{kwargs['name']}' already exists")
        profile = await self.conn_repo.create(**kwargs)
        logger.info("connection_profile_created", name=profile.name)
        return profile

    async def list_connection_profiles(
        self, offset: int = 0, limit: int = 50
    ) -> tuple[Sequence[ConnectionProfile], int]:
        return await self.conn_repo.get_all(offset=offset, limit=limit)

    async def get_connection_profile(self, profile_id: UUID) -> ConnectionProfile:
        profile = await self.conn_repo.get_by_id(profile_id)
        if profile is None:
            raise NotFoundError(f"Connection profile {profile_id} not found")
        return profile

    # --- Data Quality Rules ---
    async def create_dq_rule(self, **kwargs: Any) -> DataQualityRule:
        rule = await self.dq_repo.create(**kwargs)
        logger.info("dq_rule_created", name=rule.rule_name)
        return rule

    async def get_rules_for_table(
        self, table_config_id: UUID
    ) -> Sequence[DataQualityRule]:
        return await self.dq_repo.get_for_table(table_config_id)
