"""Report generation commands."""

import json
from datetime import datetime
from pathlib import Path

import click
from rich.console import Console

from src.cli.client import api_request

console = Console()


@click.group("report")
def report() -> None:
    """Generate HTML and CSV reports."""
    pass


@report.command("jobs")
@click.option("--format", "-f", "fmt", type=click.Choice(["html", "csv", "json"]), default="html")
@click.option("--output", "-o", default=None, help="Output file path")
@click.option("--type", "-t", "job_type", help="Filter by job type")
def report_jobs(fmt: str, output: str | None, job_type: str | None) -> None:
    """Generate a job execution report."""
    params: dict = {"page_size": 1000}
    if job_type:
        params["job_type"] = job_type
    data = api_request("GET", "/jobs", params=params)
    items = data.get("items", []) if isinstance(data, dict) else data

    output_path = output or f"report_jobs_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{fmt}"
    _generate_report(items, output_path, fmt, "Job Execution Report", _JOB_COLUMNS)
    console.print(f"[green]Report generated:[/green] {output_path}")


@report.command("errors")
@click.option("--format", "-f", "fmt", type=click.Choice(["html", "csv", "json"]), default="html")
@click.option("--output", "-o", default=None, help="Output file path")
@click.option("--limit", "-n", default=200, help="Number of errors")
def report_errors(fmt: str, output: str | None, limit: int) -> None:
    """Generate an error report."""
    data = api_request("GET", "/admin/errors", params={"limit": limit})
    items = data if isinstance(data, list) else data.get("items", [])

    output_path = output or f"report_errors_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{fmt}"
    _generate_report(items, output_path, fmt, "Error Report", _ERROR_COLUMNS)
    console.print(f"[green]Report generated:[/green] {output_path}")


@report.command("audit")
@click.option("--format", "-f", "fmt", type=click.Choice(["html", "csv", "json"]), default="html")
@click.option("--output", "-o", default=None, help="Output file path")
@click.option("--limit", "-n", default=500, help="Number of entries")
def report_audit(fmt: str, output: str | None, limit: int) -> None:
    """Generate an audit trail report."""
    data = api_request("GET", "/admin/audit", params={"limit": limit})
    items = data if isinstance(data, list) else data.get("items", [])

    output_path = output or f"report_audit_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{fmt}"
    _generate_report(items, output_path, fmt, "Audit Trail Report", _AUDIT_COLUMNS)
    console.print(f"[green]Report generated:[/green] {output_path}")


@report.command("sla")
@click.option("--format", "-f", "fmt", type=click.Choice(["html", "csv", "json"]), default="html")
@click.option("--output", "-o", default=None, help="Output file path")
def report_sla(fmt: str, output: str | None) -> None:
    """Generate an SLA compliance report."""
    dashboard = api_request("GET", "/admin/dashboard")
    breaches = api_request("GET", "/admin/sla/breaches", params={"limit": 200})

    breach_items = breaches if isinstance(breaches, list) else breaches.get("items", [])
    sla_data = dashboard.get("sla", {}) if isinstance(dashboard, dict) else {}

    output_path = output or f"report_sla_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{fmt}"

    if fmt == "html":
        html = _generate_sla_html(sla_data, breach_items)
        Path(output_path).write_text(html)
    elif fmt == "csv":
        _generate_report(breach_items, output_path, "csv", "SLA Breaches", _SLA_COLUMNS)
    else:
        Path(output_path).write_text(json.dumps({"compliance": sla_data, "breaches": breach_items}, indent=2, default=str))

    console.print(f"[green]SLA report generated:[/green] {output_path}")


# --- Column definitions ---
_JOB_COLUMNS = [
    ("ID", "id"), ("Name", "name"), ("Type", "job_type"),
    ("Schedule", "schedule_cron"), ("Enabled", "is_enabled"),
    ("Retries", "max_retries"), ("Timeout (s)", "timeout_seconds"),
    ("Created", "created_at"), ("Updated", "updated_at"),
]

_ERROR_COLUMNS = [
    ("ID", "id"), ("Severity", "severity"), ("Code", "error_code"),
    ("Service", "source_service"), ("Message", "message"),
    ("Job Run", "job_run_id"), ("Time", "timestamp"),
]

_AUDIT_COLUMNS = [
    ("Time", "timestamp"), ("User", "username"), ("Action", "action"),
    ("Resource", "resource_type"), ("Resource ID", "resource_id"),
    ("IP", "ip_address"),
]

_SLA_COLUMNS = [
    ("Run ID", "job_run_id"), ("Expected (min)", "expected_minutes"),
    ("Actual (min)", "actual_minutes"), ("Reason", "breach_reason"),
    ("Evaluated", "evaluated_at"),
]


def _generate_report(
    items: list,
    output_path: str,
    fmt: str,
    title: str,
    columns: list[tuple[str, str]],
) -> None:
    if fmt == "html":
        html = _generate_html(items, title, columns)
        Path(output_path).write_text(html)
    elif fmt == "csv":
        _generate_csv(items, output_path, columns)
    else:
        Path(output_path).write_text(json.dumps(items, indent=2, default=str))


def _generate_csv(items: list, output_path: str, columns: list[tuple[str, str]]) -> None:
    import csv

    with open(output_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([col[0] for col in columns])
        for item in items:
            writer.writerow([str(item.get(col[1], "")) for col in columns])


def _generate_html(items: list, title: str, columns: list[tuple[str, str]]) -> str:
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    rows_html = ""
    for item in items:
        cells = "".join(f"<td>{_escape_html(str(item.get(col[1], '')))}</td>" for col in columns)
        rows_html += f"<tr>{cells}</tr>\n"

    headers = "".join(f"<th>{col[0]}</th>" for col in columns)

    return _HTML_TEMPLATE.format(
        title=title,
        generated=now,
        count=len(items),
        headers=headers,
        rows=rows_html,
    )


def _generate_sla_html(sla_data: dict, breaches: list) -> str:
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    compliance_rows = ""
    for job_type, info in sla_data.items():
        if isinstance(info, dict):
            pct = info.get("compliance_pct", 100)
            color = "#28a745" if pct >= 95 else "#ffc107" if pct >= 80 else "#dc3545"
            compliance_rows += f"""
            <tr>
                <td>{job_type}</td>
                <td style="color: {color}; font-weight: bold;">{pct:.1f}%</td>
                <td>{info.get('total_runs', 0)}</td>
                <td>{info.get('breached_runs', 0)}</td>
            </tr>"""

    breach_rows = ""
    for b in breaches:
        breach_rows += f"""
        <tr>
            <td>{str(b.get('job_run_id', ''))[:8]}</td>
            <td>{b.get('expected_minutes', '-')}</td>
            <td>{b.get('actual_minutes', '-')}</td>
            <td>{b.get('breach_reason', '-')}</td>
            <td>{str(b.get('evaluated_at', ''))[:19]}</td>
        </tr>"""

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>SLA Compliance Report</title>
{_CSS}
</head>
<body>
<div class="container">
<h1>SLA Compliance Report</h1>
<p class="meta">Generated: {now}</p>

<h2>Compliance Summary</h2>
<table>
<thead><tr><th>Job Type</th><th>Compliance</th><th>Total Runs</th><th>Breaches</th></tr></thead>
<tbody>{compliance_rows}</tbody>
</table>

<h2>Breach History ({len(breaches)} breaches)</h2>
<table>
<thead><tr><th>Run ID</th><th>Expected (min)</th><th>Actual (min)</th><th>Reason</th><th>Time</th></tr></thead>
<tbody>{breach_rows}</tbody>
</table>
</div>
</body>
</html>"""


def _escape_html(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


_CSS = """<style>
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; }
.container { max-width: 1200px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
h1 { color: #1a73e8; border-bottom: 2px solid #1a73e8; padding-bottom: 10px; }
h2 { color: #333; margin-top: 30px; }
.meta { color: #666; font-size: 0.9em; }
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th { background: #1a73e8; color: white; padding: 10px; text-align: left; font-weight: 600; }
td { padding: 8px 10px; border-bottom: 1px solid #e0e0e0; }
tr:nth-child(even) { background: #f9f9f9; }
tr:hover { background: #e8f0fe; }
.badge { padding: 3px 8px; border-radius: 4px; font-size: 0.85em; font-weight: 600; }
.badge-success { background: #d4edda; color: #155724; }
.badge-danger { background: #f8d7da; color: #721c24; }
.badge-warning { background: #fff3cd; color: #856404; }
</style>"""

_HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>{title}</title>
{css}
</head>
<body>
<div class="container">
<h1>{title}</h1>
<p class="meta">Generated: {generated} | Total: {count} records</p>
<table>
<thead><tr>{headers}</tr></thead>
<tbody>{rows}</tbody>
</table>
</div>
</body>
</html>""".replace("{css}", _CSS)
