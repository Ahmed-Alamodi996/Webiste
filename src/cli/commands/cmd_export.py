"""Oracle export commands."""

import click
from rich.console import Console

from src.cli.client import api_request

console = Console()


@click.group("export")
def export() -> None:
    """Export Oracle tables to CSV."""
    pass


@export.command("table")
@click.argument("table_name")
@click.option("--columns", "-c", help="Columns to export (comma-separated, default: all)")
@click.option("--where", "-w", help="WHERE clause filter")
@click.option("--chunk-size", default=50000, help="Rows per chunk (default: 50000)")
@click.option("--output-dir", "-o", help="Output directory")
def export_table(
    table_name: str,
    columns: str | None,
    where: str | None,
    chunk_size: int,
    output_dir: str | None,
) -> None:
    """Export an Oracle table to CSV files."""
    payload: dict = {
        "table_name": table_name,
        "chunk_size": chunk_size,
    }
    if columns:
        payload["columns"] = [c.strip() for c in columns.split(",")]
    if where:
        payload["where_clause"] = where
    if output_dir:
        payload["output_dir"] = output_dir

    console.print(f"[blue]Exporting [bold]{table_name}[/bold]...[/blue]")
    result = api_request("POST", "/export/table", json_data=payload)

    console.print(f"[green]Export complete![/green]")
    if isinstance(result, dict):
        console.print(f"  File: {result.get('output_path', 'N/A')}")
        console.print(f"  Rows: {result.get('total_rows', 'N/A')}")
        console.print(f"  Chunks: {result.get('chunks', 'N/A')}")


@export.command("snapshot")
@click.argument("table_name")
@click.option("--date-column", required=True, help="Date column for partitioning")
@click.option("--month", required=True, help="Month in YYYY-MM format")
def export_snapshot(table_name: str, date_column: str, month: str) -> None:
    """Create a historical monthly snapshot export."""
    payload = {
        "table_name": table_name,
        "date_column": date_column,
        "snapshot_month": month,
    }
    console.print(f"[blue]Creating snapshot for [bold]{table_name}[/bold] ({month})...[/blue]")
    result = api_request("POST", "/export/historical-snapshot", json_data=payload)
    console.print(f"[green]Snapshot created![/green]")
    if isinstance(result, dict):
        console.print(f"  File: {result.get('output_path', 'N/A')}")
