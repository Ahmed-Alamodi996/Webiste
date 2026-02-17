"""Oracle Export API endpoints."""

from fastapi import APIRouter
from pydantic import BaseModel, Field

from src.api.deps import DBSession, require_permission
from src.services.oracle_export import OracleExportService

router = APIRouter()


class ExportRequest(BaseModel):
    table_name: str
    columns: list[str]
    where_clause: str | None = None
    chunk_size: int = Field(default=50000, ge=1000, le=1000000)


class HistoricalSnapshotRequest(BaseModel):
    source_table: str
    key_column: str
    where_clause: str | None = None


@router.post(
    "/table",
    dependencies=[require_permission("export:execute")],
)
async def export_oracle_table(data: ExportRequest):
    """Export an Oracle table to CSV (chunked, memory-safe)."""
    service = OracleExportService()
    result = await service.export_table(
        table_name=data.table_name,
        columns=data.columns,
        where_clause=data.where_clause,
        chunk_size=data.chunk_size,
    )
    return result


@router.post(
    "/historical-snapshot",
    dependencies=[require_permission("export:execute")],
)
async def create_historical_snapshot(data: HistoricalSnapshotRequest):
    """Create/update a monthly historical snapshot in Oracle."""
    service = OracleExportService()
    result = await service.create_historical_snapshot(
        source_table=data.source_table,
        key_column=data.key_column,
        where_clause=data.where_clause,
    )
    return result
