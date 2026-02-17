"""
RA Platform CLI - Main entry point.

Usage:
    ra <command> [options]

Commands:
    login           Authenticate with the platform
    logout          Clear saved credentials
    dashboard       Show platform dashboard
    jobs            Manage jobs (list, create, trigger, status)
    config          Manage table configs and connections
    export          Export Oracle tables
    load            Load CSV/Excel into Oracle
    refresh         Refresh materialized views
    logs            View audit trail and error logs
    report          Generate HTML/CSV reports
    yaml            Import/export YAML config files
    health          Check platform health
    server          Start/stop the platform server
"""

import click
from rich.console import Console

from src.cli.commands import (
    cmd_config,
    cmd_dashboard,
    cmd_export,
    cmd_health,
    cmd_jobs,
    cmd_load,
    cmd_logs,
    cmd_refresh,
    cmd_report,
    cmd_server,
    cmd_yaml,
)

console = Console()

BANNER = r"""
[bold blue]
  ██████╗  █████╗     ██████╗ ██╗      █████╗ ████████╗███████╗ ██████╗ ██████╗ ███╗   ███╗
  ██╔══██╗██╔══██╗    ██╔══██╗██║     ██╔══██╗╚══██╔══╝██╔════╝██╔═══██╗██╔══██╗████╗ ████║
  ██████╔╝███████║    ██████╔╝██║     ███████║   ██║   █████╗  ██║   ██║██████╔╝██╔████╔██║
  ██╔══██╗██╔══██║    ██╔═══╝ ██║     ██╔══██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║
  ██║  ██║██║  ██║    ██║     ███████╗██║  ██║   ██║   ██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
[/bold blue]
  [dim]Revenue Assurance Data Automation Platform[/dim]
"""


@click.group()
@click.version_option(version="1.0.0", prog_name="ra-platform")
@click.option("--api-url", envvar="RA_API_URL", default="http://localhost:8000/api/v1", help="API base URL")
@click.pass_context
def cli(ctx: click.Context, api_url: str) -> None:
    """RA Platform - Revenue Assurance Data Automation CLI."""
    ctx.ensure_object(dict)
    ctx.obj["api_url"] = api_url


# --- Auth commands ---
@cli.command("login")
@click.option("--username", "-u", prompt=True, help="Username")
@click.option("--password", "-p", prompt=True, hide_input=True, help="Password")
def login(username: str, password: str) -> None:
    """Authenticate with the RA Platform."""
    from src.cli.client import api_request, save_token

    result = api_request(
        "POST",
        "/auth/login",
        json_data={"username": username, "password": password},
        require_auth=False,
    )
    token = result.get("access_token", "")
    save_token(token)
    console.print(f"[green]Logged in as [bold]{username}[/bold].[/green]")


@cli.command("logout")
def logout() -> None:
    """Clear saved credentials."""
    from src.cli.client import clear_token

    clear_token()
    console.print("[dim]Logged out. Token cleared.[/dim]")


# --- Register command groups ---
cli.add_command(cmd_dashboard.dashboard)
cli.add_command(cmd_jobs.jobs)
cli.add_command(cmd_config.config)
cli.add_command(cmd_export.export)
cli.add_command(cmd_load.load)
cli.add_command(cmd_refresh.refresh)
cli.add_command(cmd_logs.logs)
cli.add_command(cmd_report.report)
cli.add_command(cmd_yaml.yaml)
cli.add_command(cmd_health.health)
cli.add_command(cmd_server.server)


def main() -> None:
    """CLI entry point."""
    cli()


if __name__ == "__main__":
    main()
