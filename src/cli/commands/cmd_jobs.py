"""Job management commands."""

import json

import click
from rich.console import Console

from src.cli.client import api_request
from src.cli.formatters import print_jobs_table, print_runs_table

console = Console()


@click.group("jobs")
def jobs() -> None:
    """Manage jobs - list, create, trigger, view runs."""
    pass


@jobs.command("list")
@click.option("--type", "-t", "job_type", help="Filter by type: export|load|refresh|dependency_scan")
@click.option("--page", default=1, help="Page number")
@click.option("--limit", default=50, help="Items per page")
def list_jobs(job_type: str | None, page: int, limit: int) -> None:
    """List all configured jobs."""
    params: dict = {"page": page, "page_size": limit}
    if job_type:
        params["job_type"] = job_type
    data = api_request("GET", "/jobs", params=params)
    items = data.get("items", []) if isinstance(data, dict) else data
    total = data.get("total", len(items)) if isinstance(data, dict) else len(items)
    print_jobs_table(items)
    console.print(f"[dim]Showing {len(items)} of {total} jobs[/dim]")


@jobs.command("show")
@click.argument("job_id")
def show_job(job_id: str) -> None:
    """Show detailed job information."""
    data = api_request("GET", f"/jobs/{job_id}")
    console.print_json(json.dumps(data, default=str))


@jobs.command("create")
@click.option("--name", "-n", required=True, help="Job name")
@click.option("--type", "-t", "job_type", required=True, type=click.Choice(["export", "load", "refresh", "dependency_scan"]))
@click.option("--cron", help="Cron schedule (e.g., '0 2 * * *')")
@click.option("--config", "-c", "config_json", help="JSON config string or @file.json")
@click.option("--retries", default=3, help="Max retries (0-10)")
@click.option("--timeout", default=3600, help="Timeout in seconds")
@click.option("--description", "-d", help="Job description")
def create_job(
    name: str,
    job_type: str,
    cron: str | None,
    config_json: str | None,
    retries: int,
    timeout: int,
    description: str | None,
) -> None:
    """Create a new job definition."""
    config = {}
    if config_json:
        if config_json.startswith("@"):
            with open(config_json[1:]) as f:
                config = json.load(f)
        else:
            config = json.loads(config_json)

    payload = {
        "name": name,
        "job_type": job_type,
        "config": config,
        "max_retries": retries,
        "timeout_seconds": timeout,
    }
    if cron:
        payload["schedule_cron"] = cron
    if description:
        payload["description"] = description

    result = api_request("POST", "/jobs", json_data=payload)
    console.print(f"[green]Job created:[/green] {result.get('id')}")


@jobs.command("trigger")
@click.argument("job_id")
@click.option("--params", "-p", "params_json", default="{}", help="JSON params or @file.json")
def trigger_job(job_id: str, params_json: str) -> None:
    """Trigger a job for immediate execution."""
    params = {}
    if params_json.startswith("@"):
        with open(params_json[1:]) as f:
            params = json.load(f)
    else:
        params = json.loads(params_json)

    result = api_request("POST", "/jobs/trigger", json_data={"job_id": job_id, "params": params})
    console.print(f"[green]Job triggered![/green]")
    console.print(f"  Run ID: [bold]{result.get('job_run_id')}[/bold]")
    console.print(f"  Status: {result.get('status')}")


@jobs.command("runs")
@click.argument("job_id")
@click.option("--limit", default=20, help="Number of runs to show")
def list_runs(job_id: str, limit: int) -> None:
    """List recent runs for a job."""
    data = api_request("GET", f"/jobs/{job_id}/runs", params={"limit": limit})
    runs = data if isinstance(data, list) else data.get("items", [])
    print_runs_table(runs)


@jobs.command("status")
@click.argument("run_id")
def run_status(run_id: str) -> None:
    """Get detailed status of a job run."""
    data = api_request("GET", f"/jobs/runs/{run_id}/status")
    console.print_json(json.dumps(data, default=str))


@jobs.command("enable")
@click.argument("job_id")
def enable_job(job_id: str) -> None:
    """Enable a job."""
    api_request("PUT", f"/jobs/{job_id}", json_data={"is_enabled": True})
    console.print(f"[green]Job {job_id[:8]} enabled.[/green]")


@jobs.command("disable")
@click.argument("job_id")
def disable_job(job_id: str) -> None:
    """Disable a job."""
    api_request("PUT", f"/jobs/{job_id}", json_data={"is_enabled": False})
    console.print(f"[yellow]Job {job_id[:8]} disabled.[/yellow]")


@jobs.command("delete")
@click.argument("job_id")
@click.confirmation_option(prompt="Are you sure you want to delete this job?")
def delete_job(job_id: str) -> None:
    """Delete a job definition."""
    api_request("DELETE", f"/jobs/{job_id}")
    console.print(f"[red]Job {job_id[:8]} deleted.[/red]")
