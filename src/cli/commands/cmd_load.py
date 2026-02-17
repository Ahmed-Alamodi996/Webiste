"""ETL loader commands."""

import click
from rich.console import Console

from src.cli.client import api_request

console = Console()


@click.group("load")
def load() -> None:
    """Load CSV/Excel data into Oracle via SQL*Loader."""
    pass


@load.command("csv")
@click.argument("file_path")
@click.option("--table", "-t", required=True, help="Destination Oracle table")
@click.option("--columns", "-c", help="Column mapping (comma-separated)")
@click.option("--delimiter", default=",", help="CSV delimiter (default: comma)")
@click.option("--skip-rows", default=0, type=int, help="Header rows to skip")
@click.option("--config-id", help="Use existing table config ID")
def load_csv(
    file_path: str,
    table: str,
    columns: str | None,
    delimiter: str,
    skip_rows: int,
    config_id: str | None,
) -> None:
    """Load a CSV file into Oracle."""
    payload: dict = {
        "file_path": file_path,
        "destination_table": table,
        "delimiter": delimiter,
        "skip_rows": skip_rows,
    }
    if columns:
        payload["columns"] = [c.strip() for c in columns.split(",")]
    if config_id:
        payload["config_id"] = config_id

    console.print(f"[blue]Loading [bold]{file_path}[/bold] -> [bold]{table}[/bold]...[/blue]")
    result = api_request("POST", "/loader/csv", json_data=payload)
    console.print(f"[green]Load complete![/green]")
    if isinstance(result, dict):
        console.print(f"  Records loaded: {result.get('records_loaded', 'N/A')}")
        console.print(f"  Records failed: {result.get('records_failed', 'N/A')}")


@load.command("excel")
@click.argument("file_path")
@click.option("--table", "-t", required=True, help="Destination Oracle table")
@click.option("--sheet", default="Sheet1", help="Excel sheet name")
@click.option("--columns", "-c", help="Column mapping (comma-separated)")
@click.option("--skip-rows", default=0, type=int, help="Header rows to skip")
@click.option("--config-id", help="Use existing table config ID")
def load_excel(
    file_path: str,
    table: str,
    sheet: str,
    columns: str | None,
    skip_rows: int,
    config_id: str | None,
) -> None:
    """Load an Excel file into Oracle."""
    payload: dict = {
        "file_path": file_path,
        "destination_table": table,
        "sheet_name": sheet,
        "skip_rows": skip_rows,
    }
    if columns:
        payload["columns"] = [c.strip() for c in columns.split(",")]
    if config_id:
        payload["config_id"] = config_id

    console.print(f"[blue]Loading [bold]{file_path}[/bold] (sheet: {sheet}) -> [bold]{table}[/bold]...[/blue]")
    result = api_request("POST", "/loader/excel", json_data=payload)
    console.print(f"[green]Load complete![/green]")
    if isinstance(result, dict):
        console.print(f"  Records loaded: {result.get('records_loaded', 'N/A')}")
        console.print(f"  Records failed: {result.get('records_failed', 'N/A')}")
