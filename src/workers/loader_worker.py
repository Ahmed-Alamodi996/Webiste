"""ETL Loader job worker handler."""

from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from src.config.logging import get_logger
from src.services.etl_loader import ETLLoaderService

logger = get_logger(__name__)


async def handle_loader_job(
    payload: dict[str, Any], session: AsyncSession
) -> dict[str, Any]:
    """
    Handle a loader job:
    - Read config from payload
    - Load data from CSV/Excel into Oracle via SQL*Loader
    """
    config = payload.get("config", {})
    params = payload.get("params", {})

    source_type = config.get("source_type", "csv")
    source_path = config.get("source_path") or params.get("source_path")
    destination_table = config.get("destination_table")
    source_columns = config.get("source_columns", [])
    destination_columns = config.get("destination_columns", [])
    date_column = config.get("date_column")
    skip_rows = config.get("skip_rows", 0)
    backup_dir = config.get("backup_dir")

    if not source_path or not destination_table:
        raise ValueError("source_path and destination_table are required")

    service = ETLLoaderService()

    if source_type == "excel":
        result = await service.load_from_excel(
            excel_path=source_path,
            destination_table=destination_table,
            source_columns=source_columns,
            destination_columns=destination_columns,
            date_column=date_column,
            skip_rows=skip_rows,
            backup_dir=backup_dir,
        )
    else:
        result = await service.load_from_csv(
            csv_path=source_path,
            destination_table=destination_table,
            source_columns=source_columns,
            destination_columns=destination_columns,
            date_column=date_column,
            skip_rows=skip_rows,
            backup_dir=backup_dir,
        )

    return {
        "records_processed": result.get("records_loaded", 0),
        "records_rejected": result.get("records_rejected", 0),
        "source_file": result.get("source_file"),
        "destination_table": destination_table,
        "duration_seconds": result.get("duration_seconds"),
    }
