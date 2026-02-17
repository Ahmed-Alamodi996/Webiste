"""Configuration repository: TableConfig, ConnectionProfile, DependencyEdge, MVRefreshStatus."""

from typing import Sequence
from uuid import UUID

from sqlalchemy import and_, delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.domain.config import ConnectionProfile, DataQualityRule, TableConfig
from src.models.domain.dependency import DependencyEdge, MVRefreshStatus
from src.repositories.base import BaseRepository


class TableConfigRepository(BaseRepository[TableConfig]):
    def __init__(self, session: AsyncSession):
        super().__init__(TableConfig, session)

    async def get_enabled_by_source_type(
        self, source_type: str
    ) -> Sequence[TableConfig]:
        result = await self.session.execute(
            select(TableConfig).where(
                and_(
                    TableConfig.source_type == source_type,
                    TableConfig.is_enabled.is_(True),
                )
            )
        )
        return result.scalars().all()

    async def get_by_schedule_day(self, day: int) -> Sequence[TableConfig]:
        result = await self.session.execute(
            select(TableConfig).where(
                and_(
                    TableConfig.schedule_day == day,
                    TableConfig.is_enabled.is_(True),
                )
            )
        )
        return result.scalars().all()


class ConnectionProfileRepository(BaseRepository[ConnectionProfile]):
    def __init__(self, session: AsyncSession):
        super().__init__(ConnectionProfile, session)

    async def get_by_name(self, name: str) -> ConnectionProfile | None:
        result = await self.session.execute(
            select(ConnectionProfile).where(ConnectionProfile.name == name)
        )
        return result.scalar_one_or_none()

    async def get_active(self) -> Sequence[ConnectionProfile]:
        result = await self.session.execute(
            select(ConnectionProfile).where(ConnectionProfile.is_active.is_(True))
        )
        return result.scalars().all()


class DependencyGraphRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def save_edges(
        self, edges: list[dict], scan_run_id: UUID
    ) -> int:
        """Bulk insert dependency edges for a scan run."""
        count = 0
        for edge in edges:
            obj = DependencyEdge(
                object_name=edge["object_name"],
                object_type=edge["object_type"],
                depends_on=edge["depends_on"],
                depends_on_type=edge["depends_on_type"],
                topo_level=edge.get("topo_level"),
                scan_run_id=scan_run_id,
            )
            self.session.add(obj)
            count += 1
        await self.session.flush()
        return count

    async def get_latest_graph(self) -> Sequence[DependencyEdge]:
        """Get the most recent dependency scan results."""
        # Find latest scan_run_id
        latest = await self.session.execute(
            select(DependencyEdge.scan_run_id)
            .order_by(DependencyEdge.scanned_at.desc())
            .limit(1)
        )
        scan_id = latest.scalar_one_or_none()
        if scan_id is None:
            return []

        result = await self.session.execute(
            select(DependencyEdge).where(
                DependencyEdge.scan_run_id == scan_id
            )
        )
        return result.scalars().all()

    async def clear_old_scans(self, keep_latest: int = 5) -> int:
        """Remove old dependency scans, keeping the N most recent."""
        scans = await self.session.execute(
            select(DependencyEdge.scan_run_id)
            .distinct()
            .order_by(DependencyEdge.scanned_at.desc())
        )
        all_scans = [row[0] for row in scans.all()]
        if len(all_scans) <= keep_latest:
            return 0

        old_scans = all_scans[keep_latest:]
        result = await self.session.execute(
            delete(DependencyEdge).where(
                DependencyEdge.scan_run_id.in_(old_scans)
            )
        )
        await self.session.flush()
        return result.rowcount


class MVRefreshStatusRepository(BaseRepository[MVRefreshStatus]):
    def __init__(self, session: AsyncSession):
        super().__init__(MVRefreshStatus, session)

    async def get_by_job_run(
        self, job_run_id: UUID
    ) -> Sequence[MVRefreshStatus]:
        result = await self.session.execute(
            select(MVRefreshStatus)
            .where(MVRefreshStatus.job_run_id == job_run_id)
            .order_by(MVRefreshStatus.topo_level)
        )
        return result.scalars().all()

    async def get_pending_for_run(
        self, job_run_id: UUID
    ) -> Sequence[MVRefreshStatus]:
        result = await self.session.execute(
            select(MVRefreshStatus).where(
                and_(
                    MVRefreshStatus.job_run_id == job_run_id,
                    MVRefreshStatus.status == "pending",
                )
            )
        )
        return result.scalars().all()


class DataQualityRuleRepository(BaseRepository[DataQualityRule]):
    def __init__(self, session: AsyncSession):
        super().__init__(DataQualityRule, session)

    async def get_for_table(
        self, table_config_id: UUID
    ) -> Sequence[DataQualityRule]:
        result = await self.session.execute(
            select(DataQualityRule).where(
                and_(
                    DataQualityRule.table_config_id == table_config_id,
                    DataQualityRule.is_enabled.is_(True),
                )
            )
        )
        return result.scalars().all()
