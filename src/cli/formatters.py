"""Rich formatters for CLI output - tables, panels, trees."""

from datetime import datetime
from typing import Any

from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich.tree import Tree

console = Console()


STATUS_STYLES = {
    "success": "green",
    "completed": "green",
    "running": "yellow",
    "in_progress": "yellow",
    "pending": "blue",
    "queued": "blue",
    "failed": "red",
    "error": "red",
    "timeout": "red",
    "cancelled": "dim",
    "healthy": "green",
    "degraded": "yellow",
    "unhealthy": "red",
    "warning": "yellow",
    "critical": "red bold",
}


def styled_status(status: str) -> Text:
    style = STATUS_STYLES.get(status.lower(), "white")
    return Text(status.upper(), style=style)


def format_duration(seconds: float | None) -> str:
    if seconds is None:
        return "-"
    if seconds < 60:
        return f"{seconds:.1f}s"
    minutes = seconds / 60
    if minutes < 60:
        return f"{minutes:.1f}m"
    hours = minutes / 60
    return f"{hours:.1f}h"


def format_timestamp(ts: str | None) -> str:
    if not ts:
        return "-"
    try:
        dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    except (ValueError, AttributeError):
        return str(ts)[:19]


def format_number(n: int | None) -> str:
    if n is None:
        return "-"
    return f"{n:,}"


def print_jobs_table(jobs: list[dict[str, Any]], title: str = "Jobs") -> None:
    table = Table(title=title, show_lines=True)
    table.add_column("ID", style="dim", max_width=8)
    table.add_column("Name", style="bold")
    table.add_column("Type", style="cyan")
    table.add_column("Schedule")
    table.add_column("Enabled")
    table.add_column("Retries")
    table.add_column("Timeout")

    for j in jobs:
        job_id = str(j["id"])[:8]
        enabled = Text("YES", style="green") if j.get("is_enabled") else Text("NO", style="red")
        table.add_row(
            job_id,
            j["name"],
            j["job_type"],
            j.get("schedule_cron") or "-",
            enabled,
            str(j.get("max_retries", 3)),
            format_duration(j.get("timeout_seconds")),
        )
    console.print(table)


def print_runs_table(runs: list[dict[str, Any]], title: str = "Job Runs") -> None:
    table = Table(title=title, show_lines=True)
    table.add_column("Run ID", style="dim", max_width=8)
    table.add_column("Status")
    table.add_column("Triggered By")
    table.add_column("Started")
    table.add_column("Duration")
    table.add_column("Records", justify="right")
    table.add_column("Failures", justify="right")

    for r in runs:
        run_id = str(r["id"])[:8]
        table.add_row(
            run_id,
            styled_status(r["status"]),
            r.get("triggered_by", "-"),
            format_timestamp(r.get("started_at")),
            format_duration(r.get("duration_seconds")),
            format_number(r.get("records_processed")),
            format_number(r.get("records_failed")),
        )
    console.print(table)


def print_configs_table(configs: list[dict[str, Any]], title: str = "Table Configs") -> None:
    table = Table(title=title, show_lines=True)
    table.add_column("ID", style="dim", max_width=8)
    table.add_column("Name", style="bold")
    table.add_column("Source Type", style="cyan")
    table.add_column("Source Table")
    table.add_column("Dest Table")
    table.add_column("Enabled")

    for c in configs:
        cfg_id = str(c["id"])[:8]
        enabled = Text("YES", style="green") if c.get("is_enabled") else Text("NO", style="red")
        table.add_row(
            cfg_id,
            c["name"],
            c.get("source_type", "-"),
            c.get("source_table_name", "-"),
            c.get("destination_table_name", "-"),
            enabled,
        )
    console.print(table)


def print_connections_table(conns: list[dict[str, Any]], title: str = "Connections") -> None:
    table = Table(title=title, show_lines=True)
    table.add_column("ID", style="dim", max_width=8)
    table.add_column("Name", style="bold")
    table.add_column("Type", style="cyan")
    table.add_column("Host")
    table.add_column("Port")
    table.add_column("Database")
    table.add_column("Active")

    for c in conns:
        conn_id = str(c["id"])[:8]
        active = Text("YES", style="green") if c.get("is_active") else Text("NO", style="red")
        table.add_row(
            conn_id,
            c["name"],
            c.get("db_type", "-"),
            c.get("host", "-"),
            str(c.get("port", "-")),
            c.get("database_name", "-"),
            active,
        )
    console.print(table)


def print_errors_table(errors: list[dict[str, Any]], title: str = "Errors") -> None:
    table = Table(title=title, show_lines=True)
    table.add_column("ID", style="dim", max_width=8)
    table.add_column("Severity")
    table.add_column("Code", style="cyan")
    table.add_column("Service")
    table.add_column("Message", max_width=60)
    table.add_column("Time")

    for e in errors:
        err_id = str(e["id"])[:8]
        table.add_row(
            err_id,
            styled_status(e.get("severity", "error")),
            e.get("error_code", "-"),
            e.get("source_service", "-"),
            (e.get("message", "")[:60] + "...") if len(e.get("message", "")) > 60 else e.get("message", ""),
            format_timestamp(e.get("timestamp")),
        )
    console.print(table)


def print_audit_table(logs: list[dict[str, Any]], title: str = "Audit Trail") -> None:
    table = Table(title=title, show_lines=True)
    table.add_column("Time")
    table.add_column("User", style="bold")
    table.add_column("Action", style="cyan")
    table.add_column("Resource")
    table.add_column("Resource ID", style="dim", max_width=8)
    table.add_column("IP")

    for log in logs:
        table.add_row(
            format_timestamp(log.get("timestamp")),
            log.get("username", "-"),
            log.get("action", "-"),
            log.get("resource_type", "-"),
            str(log.get("resource_id", "-"))[:8],
            log.get("ip_address", "-"),
        )
    console.print(table)


def print_dashboard(data: dict[str, Any]) -> None:
    """Print a rich admin dashboard panel."""
    jobs = data.get("jobs", {})
    sla = data.get("sla", {})
    errors = data.get("errors", {})

    # Header
    console.print()
    console.rule("[bold blue]RA Platform Dashboard[/bold blue]")
    console.print()

    # Jobs panel
    stats = jobs.get("stats_24h", {})
    job_text = (
        f"  Active Runs:  [bold yellow]{jobs.get('active_runs', 0)}[/bold yellow]\n"
        f"  Success (24h): [green]{stats.get('success', 0)}[/green]\n"
        f"  Failed (24h):  [red]{stats.get('failed', 0)}[/red]\n"
        f"  Pending (24h): [blue]{stats.get('pending', 0)}[/blue]"
    )
    console.print(Panel(job_text, title="[bold]Jobs[/bold]", border_style="blue"))

    # SLA panel
    sla_text = ""
    for job_type, info in sla.items():
        if isinstance(info, dict):
            compliance = info.get("compliance_pct", 100)
            color = "green" if compliance >= 95 else "yellow" if compliance >= 80 else "red"
            sla_text += f"  {job_type}: [{color}]{compliance:.1f}%[/{color}]\n"
    if not sla_text:
        sla_text = "  No SLA data available"
    console.print(Panel(sla_text.rstrip(), title="[bold]SLA Compliance[/bold]", border_style="green"))

    # Errors panel
    err_count = errors.get("unresolved_count", 0)
    err_color = "green" if err_count == 0 else "yellow" if err_count < 5 else "red"
    err_text = f"  Unresolved: [{err_color}]{err_count}[/{err_color}]"
    recent = errors.get("recent", [])
    if recent:
        err_text += "\n  Recent:"
        for e in recent[:3]:
            err_text += f"\n    [{e.get('severity', 'error')}] {e.get('message', '')[:50]}"
    console.print(Panel(err_text, title="[bold]Errors[/bold]", border_style="red"))
    console.print()


def print_mv_refresh_table(mvs: list[dict[str, Any]], title: str = "MV Refresh Status") -> None:
    table = Table(title=title, show_lines=True)
    table.add_column("MV Name", style="bold")
    table.add_column("Type", style="cyan")
    table.add_column("Status")
    table.add_column("Level", justify="right")
    table.add_column("Duration")
    table.add_column("Retries", justify="right")

    for mv in mvs:
        table.add_row(
            mv.get("mv_name", "-"),
            mv.get("refresh_type", "-"),
            styled_status(mv.get("status", "unknown")),
            str(mv.get("topo_level", "-")),
            format_duration(mv.get("duration_seconds")),
            str(mv.get("retry_count", 0)),
        )
    console.print(table)


def print_dependency_tree(edges: list[dict[str, Any]], title: str = "Dependency Graph") -> None:
    """Print dependency graph as a rich tree."""
    # Build adjacency map
    children: dict[str, list[str]] = {}
    all_nodes: set[str] = set()
    has_parent: set[str] = set()

    for edge in edges:
        parent = edge.get("depends_on", "")
        child = edge.get("object_name", "")
        if parent and child:
            children.setdefault(parent, []).append(child)
            all_nodes.add(parent)
            all_nodes.add(child)
            has_parent.add(child)

    roots = all_nodes - has_parent
    if not roots:
        console.print("[dim]No dependency data available.[/dim]")
        return

    tree = Tree(f"[bold]{title}[/bold]")
    for root in sorted(roots)[:20]:  # limit display
        _add_tree_node(tree, root, children, depth=0)

    console.print(tree)


def _add_tree_node(
    parent: Tree, name: str, children: dict[str, list[str]], depth: int
) -> None:
    if depth > 5:
        parent.add(f"[dim]... (truncated)[/dim]")
        return
    node = parent.add(f"[cyan]{name}[/cyan]")
    for child in sorted(children.get(name, []))[:10]:
        _add_tree_node(node, child, children, depth + 1)
