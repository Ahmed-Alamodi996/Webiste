"""Dashboard command - show platform overview."""

import click
from rich.console import Console

from src.cli.client import api_request
from src.cli.formatters import print_dashboard

console = Console()


@click.command("dashboard")
@click.option("--raw", is_flag=True, help="Output raw JSON")
def dashboard(raw: bool) -> None:
    """Show platform dashboard with job stats, SLA, and errors."""
    data = api_request("GET", "/admin/dashboard")
    if raw:
        import json
        console.print_json(json.dumps(data))
    else:
        print_dashboard(data)
