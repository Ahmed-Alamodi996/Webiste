"""Health check command."""

import click
from rich.console import Console
from rich.panel import Panel

from src.cli.client import api_request
from src.cli.formatters import styled_status

console = Console()


@click.command("health")
@click.option("--raw", is_flag=True, help="Output raw JSON")
def health(raw: bool) -> None:
    """Check platform health status."""
    data = api_request("GET", "/health", require_auth=False)

    if raw:
        import json
        console.print_json(json.dumps(data, default=str))
        return

    status = data.get("status", "unknown")
    version = data.get("version", "?")
    env = data.get("environment", "?")
    uptime = data.get("uptime_seconds", 0)
    checks = data.get("checks", {})

    # Format uptime
    hours = int(uptime // 3600)
    minutes = int((uptime % 3600) // 60)

    text = f"  Status:      {styled_status(status)}\n"
    text = ""
    lines = [
        f"  Status:      [{'green' if status == 'healthy' else 'red'}]{status.upper()}[/]",
        f"  Version:     {version}",
        f"  Environment: {env}",
        f"  Uptime:      {hours}h {minutes}m",
        "",
        "  Components:",
    ]
    for component, comp_status in checks.items():
        color = "green" if comp_status == "ok" else "red"
        lines.append(f"    [{color}]{component}: {comp_status}[/{color}]")

    console.print(Panel("\n".join(lines), title="[bold]Platform Health[/bold]", border_style="blue"))
