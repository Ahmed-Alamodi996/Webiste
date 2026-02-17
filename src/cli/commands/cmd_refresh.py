"""Materialized view refresh commands."""

import json

import click
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn

from src.cli.client import api_request
from src.cli.formatters import print_mv_refresh_table

console = Console()


@click.group("refresh")
def refresh() -> None:
    """Refresh Oracle materialized views."""
    pass


@refresh.command("single")
@click.argument("mv_name")
@click.option("--type", "-t", "refresh_type", default="COMPLETE", type=click.Choice(["COMPLETE", "FAST", "FORCE"]))
def refresh_single(mv_name: str, refresh_type: str) -> None:
    """Refresh a single materialized view."""
    console.print(f"[blue]Refreshing [bold]{mv_name}[/bold] ({refresh_type})...[/blue]")
    result = api_request(
        "POST",
        "/refresh/single",
        json_data={"mv_name": mv_name, "refresh_type": refresh_type},
    )
    if isinstance(result, dict):
        status = result.get("status", "unknown")
        if status == "success":
            console.print(f"[green]Refresh complete![/green] Duration: {result.get('duration_seconds', 'N/A')}s")
        else:
            console.print(f"[red]Refresh failed:[/red] {result.get('error_message', 'Unknown error')}")


@refresh.command("all")
@click.option("--parallel", "-p", default=4, help="Parallel workers per level")
@click.confirmation_option(prompt="Refresh ALL materialized views? This may take a while.")
def refresh_all(parallel: int) -> None:
    """Refresh all MVs in dependency order (parallelized per level)."""
    console.print(f"[blue]Starting full MV refresh (parallel={parallel})...[/blue]")
    result = api_request(
        "POST",
        "/refresh/all",
        json_data={"parallel_workers": parallel},
    )
    if isinstance(result, dict):
        console.print(f"[green]Full refresh initiated![/green]")
        console.print(f"  Job Run ID: [bold]{result.get('job_run_id', 'N/A')}[/bold]")
        console.print(f"  Track progress: [bold]ra refresh status {result.get('job_run_id', '')}[/bold]")


@refresh.command("status")
@click.argument("job_run_id")
def refresh_status(job_run_id: str) -> None:
    """Check MV refresh status for a job run."""
    data = api_request("GET", f"/refresh/status/{job_run_id}")
    mvs = data if isinstance(data, list) else data.get("items", [])
    print_mv_refresh_table(mvs)
