"""ETL Loader API endpoints."""

from fastapi import APIRouter
from pydantic import BaseModel

from src.api.deps import require_permission
from src.services.etl_loader import ETLLoaderService

router = APIRouter()


class LoadCSVRequest(BaseModel):
    csv_path: str
    destination_table: str
    source_columns: list[str]
    destination_columns: list[str]
    date_column: str | None = None
    skip_rows: int = 0
    backup_dir: str | None = None


class LoadExcelRequest(BaseModel):
    excel_path: str
    destination_table: str
    source_columns: list[str]
    destination_columns: list[str]
    date_column: str | None = None
    skip_rows: int = 0
    backup_dir: str | None = None


@router.post(
    "/csv",
    dependencies=[require_permission("loader:execute")],
)
async def load_csv_to_oracle(data: LoadCSVRequest):
    """Load a CSV file into Oracle via SQL*Loader."""
    service = ETLLoaderService()
    result = await service.load_from_csv(
        csv_path=data.csv_path,
        destination_table=data.destination_table,
        source_columns=data.source_columns,
        destination_columns=data.destination_columns,
        date_column=data.date_column,
        skip_rows=data.skip_rows,
        backup_dir=data.backup_dir,
    )
    return result


@router.post(
    "/excel",
    dependencies=[require_permission("loader:execute")],
)
async def load_excel_to_oracle(data: LoadExcelRequest):
    """Load an Excel file into Oracle via SQL*Loader."""
    service = ETLLoaderService()
    result = await service.load_from_excel(
        excel_path=data.excel_path,
        destination_table=data.destination_table,
        source_columns=data.source_columns,
        destination_columns=data.destination_columns,
        date_column=data.date_column,
        skip_rows=data.skip_rows,
        backup_dir=data.backup_dir,
    )
    return result
