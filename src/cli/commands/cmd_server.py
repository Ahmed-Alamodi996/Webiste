"""Server management commands."""

import click
from rich.console import Console

console = Console()


@click.group("server")
def server() -> None:
    """Start/stop the platform server locally."""
    pass


@server.command("start")
@click.option("--host", default="0.0.0.0", help="Bind host")
@click.option("--port", default=8000, help="Bind port")
@click.option("--workers", default=1, help="Number of workers")
@click.option("--reload", "auto_reload", is_flag=True, help="Auto-reload on code changes")
def start_server(host: str, port: int, workers: int, auto_reload: bool) -> None:
    """Start the RA Platform API server."""
    import subprocess
    import sys

    console.print(f"[blue]Starting RA Platform on [bold]{host}:{port}[/bold]...[/blue]")
    console.print("[dim]Press Ctrl+C to stop[/dim]")
    console.print()

    cmd = [
        sys.executable, "-m", "uvicorn",
        "src.main:app",
        "--host", host,
        "--port", str(port),
        "--workers", str(workers),
    ]
    if auto_reload:
        cmd.append("--reload")

    try:
        subprocess.run(cmd, check=True)
    except KeyboardInterrupt:
        console.print("\n[yellow]Server stopped.[/yellow]")
    except subprocess.CalledProcessError as e:
        console.print(f"[red]Server failed to start:[/red] {e}")


@server.command("worker")
@click.option("--concurrency", default=4, help="Number of concurrent job handlers")
def start_worker(concurrency: int) -> None:
    """Start the background job worker."""
    import subprocess
    import sys

    console.print(f"[blue]Starting worker (concurrency={concurrency})...[/blue]")
    try:
        subprocess.run(
            [sys.executable, "-m", "src.workers.queue"],
            check=True,
        )
    except KeyboardInterrupt:
        console.print("\n[yellow]Worker stopped.[/yellow]")


@server.command("docker-up")
@click.option("--detach", "-d", is_flag=True, help="Run in background")
@click.option("--build", is_flag=True, help="Rebuild images")
def docker_up(detach: bool, build: bool) -> None:
    """Start all services with Docker Compose."""
    import subprocess

    cmd = ["docker", "compose", "up"]
    if detach:
        cmd.append("-d")
    if build:
        cmd.append("--build")

    console.print("[blue]Starting Docker Compose stack...[/blue]")
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        console.print(f"[red]Docker Compose failed:[/red] {e}")


@server.command("docker-down")
def docker_down() -> None:
    """Stop all Docker Compose services."""
    import subprocess

    console.print("[yellow]Stopping Docker Compose stack...[/yellow]")
    subprocess.run(["docker", "compose", "down"], check=True)
    console.print("[green]All services stopped.[/green]")
