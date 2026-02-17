"""Export job worker handler."""

from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.services.oracle_export import OracleExportService

logger = get_logger(__name__)


async def handle_export_job(
    payload: dict[str, Any], session: AsyncSession
) -> dict[str, Any]:
    """
    Handle an export job:
    - Read config from payload
    - Export Oracle table(s) to CSV
    - Optionally create historical snapshots
    """
    config = payload.get("config", {})
    params = payload.get("params", {})

    table_name = config.get("table_name") or params.get("table_name")
    columns = config.get("columns", [])
    where_clause = config.get("where_clause")
    chunk_size = config.get("chunk_size", 50000)

    if not table_name:
        raise ValueError("table_name is required in job config")

    service = OracleExportService()
    result = await service.export_table(
        table_name=table_name,
        columns=columns,
        where_clause=where_clause,
        chunk_size=chunk_size,
    )

    # Create historical snapshot if configured
    key_column = config.get("key_column")
    if key_column:
        snapshot = await service.create_historical_snapshot(
            source_table=table_name,
            key_column=key_column,
            where_clause=where_clause,
        )
        result["historical_snapshot"] = snapshot

    return {
        "records_processed": result.get("records_exported", 0),
        "file_path": result.get("file_path"),
        "duration_seconds": result.get("duration_seconds"),
    }
