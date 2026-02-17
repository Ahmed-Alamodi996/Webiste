"""Config management commands - table configs and connections."""

import json

import click
from rich.console import Console

from src.cli.client import api_request
from src.cli.formatters import print_configs_table, print_connections_table

console = Console()


@click.group("config")
def config() -> None:
    """Manage table configs and connection profiles."""
    pass


# --- Table Configs ---
@config.group("tables")
def tables() -> None:
    """Manage ETL table configurations."""
    pass


@tables.command("list")
@click.option("--type", "-t", "source_type", help="Filter: postgres|csv|excel|oracle")
@click.option("--page", default=1, help="Page number")
@click.option("--limit", default=50, help="Items per page")
def list_tables(source_type: str | None, page: int, limit: int) -> None:
    """List all table configurations."""
    params: dict = {"page": page, "page_size": limit}
    if source_type:
        params["source_type"] = source_type
    data = api_request("GET", "/config/tables", params=params)
    items = data.get("items", []) if isinstance(data, dict) else data
    print_configs_table(items)


@tables.command("show")
@click.argument("config_id")
def show_table(config_id: str) -> None:
    """Show detailed table configuration."""
    data = api_request("GET", f"/config/tables/{config_id}")
    console.print_json(json.dumps(data, default=str))


@tables.command("create")
@click.option("--name", "-n", required=True, help="Config name")
@click.option("--source-type", "-t", required=True, type=click.Choice(["postgres", "csv", "excel", "oracle"]))
@click.option("--source-table", required=True, help="Source table name")
@click.option("--source-columns", required=True, help="Source columns (comma-separated)")
@click.option("--dest-table", required=True, help="Destination table name")
@click.option("--dest-columns", required=True, help="Destination columns (comma-separated)")
@click.option("--where", help="WHERE condition")
@click.option("--date-format", help="Date format string")
@click.option("--date-column", help="Date column name")
@click.option("--schedule-day", type=int, help="Day of month to run (1-31)")
@click.option("--skip-rows", type=int, default=0, help="Rows to skip in source")
@click.option("--file-pattern", help="File name pattern for CSV/Excel")
@click.option("--from-json", "json_file", help="Create from JSON file (@file.json)")
def create_table(
    name: str,
    source_type: str,
    source_table: str,
    source_columns: str,
    dest_table: str,
    dest_columns: str,
    where: str | None,
    date_format: str | None,
    date_column: str | None,
    schedule_day: int | None,
    skip_rows: int,
    file_pattern: str | None,
    json_file: str | None,
) -> None:
    """Create a new table configuration."""
    if json_file:
        with open(json_file.lstrip("@")) as f:
            payload = json.load(f)
    else:
        payload = {
            "name": name,
            "source_type": source_type,
            "source_table_name": source_table,
            "source_columns": source_columns,
            "destination_table_name": dest_table,
            "destination_columns": dest_columns,
            "skip_rows": skip_rows,
        }
        if where:
            payload["where_condition"] = where
        if date_format:
            payload["date_format"] = date_format
        if date_column:
            payload["date_column"] = date_column
        if schedule_day:
            payload["schedule_day"] = schedule_day
        if file_pattern:
            payload["file_name_pattern"] = file_pattern

    result = api_request("POST", "/config/tables", json_data=payload)
    console.print(f"[green]Config created:[/green] {result.get('id')}")


@tables.command("delete")
@click.argument("config_id")
@click.confirmation_option(prompt="Are you sure?")
def delete_table(config_id: str) -> None:
    """Delete a table configuration."""
    api_request("DELETE", f"/config/tables/{config_id}")
    console.print(f"[red]Config {config_id[:8]} deleted.[/red]")


# --- Connection Profiles ---
@config.group("connections")
def connections() -> None:
    """Manage database connection profiles."""
    pass


@connections.command("list")
def list_connections() -> None:
    """List all connection profiles."""
    data = api_request("GET", "/config/connections")
    items = data.get("items", []) if isinstance(data, dict) else data
    print_connections_table(items)


@connections.command("create")
@click.option("--name", "-n", required=True, help="Connection name")
@click.option("--type", "-t", "db_type", required=True, type=click.Choice(["oracle", "postgresql"]))
@click.option("--host", required=True, help="Database host")
@click.option("--port", required=True, type=int, help="Database port")
@click.option("--database", required=True, help="Database name/SID")
@click.option("--username", required=True, help="Database username")
@click.option("--password-env", required=True, help="Env var name holding password")
def create_connection(
    name: str,
    db_type: str,
    host: str,
    port: int,
    database: str,
    username: str,
    password_env: str,
) -> None:
    """Create a new connection profile."""
    payload = {
        "name": name,
        "db_type": db_type,
        "host": host,
        "port": port,
        "database_name": database,
        "username": username,
        "password_env_var": password_env,
    }
    result = api_request("POST", "/config/connections", json_data=payload)
    console.print(f"[green]Connection created:[/green] {result.get('id')}")
