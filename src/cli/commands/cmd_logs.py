"""Logs and audit trail commands."""

import json

import click
from rich.console import Console

from src.cli.client import api_request
from src.cli.formatters import print_audit_table, print_errors_table

console = Console()


@click.group("logs")
def logs() -> None:
    """View audit trail, errors, and SLA breaches."""
    pass


@logs.command("audit")
@click.option("--limit", "-n", default=50, help="Number of entries")
@click.option("--action", "-a", help="Filter by action (e.g., job.triggered)")
@click.option("--resource", "-r", help="Filter by resource type (e.g., job, config)")
@click.option("--raw", is_flag=True, help="Output raw JSON")
def audit(limit: int, action: str | None, resource: str | None, raw: bool) -> None:
    """View the audit trail."""
    params: dict = {"limit": limit}
    if action:
        params["action"] = action
    if resource:
        params["resource_type"] = resource

    data = api_request("GET", "/admin/audit", params=params)
    entries = data if isinstance(data, list) else data.get("items", [])

    if raw:
        console.print_json(json.dumps(entries, default=str))
    else:
        print_audit_table(entries)
    console.print(f"[dim]Showing {len(entries)} entries[/dim]")


@logs.command("errors")
@click.option("--limit", "-n", default=50, help="Number of errors")
@click.option("--raw", is_flag=True, help="Output raw JSON")
def errors(limit: int, raw: bool) -> None:
    """View unresolved errors."""
    data = api_request("GET", "/admin/errors", params={"limit": limit})
    entries = data if isinstance(data, list) else data.get("items", [])

    if raw:
        console.print_json(json.dumps(entries, default=str))
    else:
        print_errors_table(entries)
    console.print(f"[dim]{len(entries)} unresolved errors[/dim]")


@logs.command("resolve")
@click.argument("error_id")
def resolve_error(error_id: str) -> None:
    """Mark an error as resolved."""
    api_request("POST", f"/admin/errors/{error_id}/resolve")
    console.print(f"[green]Error {error_id[:8]} resolved.[/green]")


@logs.command("sla")
@click.option("--limit", "-n", default=50, help="Number of breaches")
@click.option("--type", "-t", "job_type", help="Filter by job type")
@click.option("--raw", is_flag=True, help="Output raw JSON")
def sla_breaches(limit: int, job_type: str | None, raw: bool) -> None:
    """View SLA breach history."""
    params: dict = {"limit": limit}
    if job_type:
        params["job_type"] = job_type

    data = api_request("GET", "/admin/sla/breaches", params=params)
    entries = data if isinstance(data, list) else data.get("items", [])

    if raw:
        console.print_json(json.dumps(entries, default=str))
        return

    from rich.table import Table

    table = Table(title="SLA Breaches", show_lines=True)
    table.add_column("Run ID", style="dim", max_width=8)
    table.add_column("Expected", justify="right")
    table.add_column("Actual", justify="right")
    table.add_column("Reason")
    table.add_column("Time")

    for b in entries:
        from src.cli.formatters import format_timestamp

        table.add_row(
            str(b.get("job_run_id", ""))[:8],
            f"{b.get('expected_minutes', '-')}m",
            f"{b.get('actual_minutes', '-')}m" if b.get("actual_minutes") else "-",
            b.get("breach_reason", "-"),
            format_timestamp(b.get("evaluated_at")),
        )
    console.print(table)
    console.print(f"[dim]{len(entries)} breaches[/dim]")
