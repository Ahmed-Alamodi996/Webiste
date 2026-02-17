"""
Report generation service.

Generates HTML, CSV, and JSON reports for:
- Job execution history
- Error logs
- Audit trail
- SLA compliance

Reports can be generated via:
- CLI: ra report jobs --format html
- API: GET /api/v1/reports/generate
- Dashboard: UI report generation page
"""

import csv
import io
import json
from datetime import datetime
from typing import Any

from src.config.logging import get_logger

logger = get_logger(__name__)


class ReportService:
    """Generate downloadable reports in various formats."""

    def generate_report(
        self,
        data: list[dict[str, Any]],
        report_type: str,
        output_format: str = "html",
        title: str | None = None,
    ) -> str:
        """Generate a report from data.

        Args:
            data: List of dict items to include in the report
            report_type: Type of report (jobs, errors, audit, sla)
            output_format: Output format (html, csv, json)
            title: Optional custom title

        Returns:
            Report content as a string
        """
        columns = _COLUMN_DEFS.get(report_type, [])
        title = title or _TITLES.get(report_type, "Report")

        logger.info(
            "report_generated",
            report_type=report_type,
            format=output_format,
            record_count=len(data),
        )

        if output_format == "json":
            return json.dumps(data, indent=2, default=str)
        elif output_format == "csv":
            return self._generate_csv(data, columns)
        else:
            return self._generate_html(data, columns, title)

    def _generate_csv(
        self,
        data: list[dict[str, Any]],
        columns: list[tuple[str, str]],
    ) -> str:
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow([col[0] for col in columns])
        for item in data:
            writer.writerow([str(item.get(col[1], "")) for col in columns])
        return output.getvalue()

    def _generate_html(
        self,
        data: list[dict[str, Any]],
        columns: list[tuple[str, str]],
        title: str,
    ) -> str:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        headers = "".join(f"<th>{col[0]}</th>" for col in columns)
        rows = ""
        for i, item in enumerate(data):
            cells = "".join(
                f"<td>{_escape_html(str(item.get(col[1], '')))}</td>"
                for col in columns
            )
            bg = '#f9f9f9' if i % 2 else '#fff'
            rows += f'<tr style="background:{bg}">{cells}</tr>\n'

        return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>{_escape_html(title)}</title>
<style>
body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
       margin: 0; padding: 20px; background: #f5f5f5; color: #333; }}
.container {{ max-width: 1200px; margin: 0 auto; background: #fff;
             padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,.1); }}
h1 {{ color: #1a73e8; border-bottom: 2px solid #1a73e8; padding-bottom: 10px; }}
.meta {{ color: #666; font-size: 0.9em; }}
table {{ width: 100%; border-collapse: collapse; margin-top: 15px; }}
th {{ background: #1a73e8; color: #fff; padding: 10px; text-align: left; font-weight: 600; }}
td {{ padding: 8px 10px; border-bottom: 1px solid #e0e0e0; }}
tr:hover {{ background: #e8f0fe !important; }}
</style>
</head>
<body>
<div class="container">
<h1>{_escape_html(title)}</h1>
<p class="meta">Generated: {now} | Total: {len(data)} records</p>
<table>
<thead><tr>{headers}</tr></thead>
<tbody>{rows}</tbody>
</table>
</div>
</body>
</html>"""


def _escape_html(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


# Column definitions: (display_name, dict_key)
_COLUMN_DEFS: dict[str, list[tuple[str, str]]] = {
    "jobs": [
        ("ID", "id"), ("Name", "name"), ("Type", "job_type"),
        ("Schedule", "schedule_cron"), ("Enabled", "is_enabled"),
        ("Max Retries", "max_retries"), ("Timeout (s)", "timeout_seconds"),
        ("Created", "created_at"), ("Updated", "updated_at"),
    ],
    "job_runs": [
        ("Run ID", "id"), ("Job ID", "job_id"), ("Status", "status"),
        ("Triggered By", "triggered_by"), ("Started", "started_at"),
        ("Duration (s)", "duration_seconds"), ("Records Processed", "records_processed"),
        ("Records Failed", "records_failed"), ("Error", "error_message"),
    ],
    "errors": [
        ("ID", "id"), ("Severity", "severity"), ("Error Code", "error_code"),
        ("Service", "source_service"), ("Message", "message"),
        ("Job Run", "job_run_id"), ("Timestamp", "timestamp"),
    ],
    "audit": [
        ("Timestamp", "timestamp"), ("User", "username"), ("Action", "action"),
        ("Resource Type", "resource_type"), ("Resource ID", "resource_id"),
        ("Details", "details"), ("IP Address", "ip_address"),
    ],
    "sla_breaches": [
        ("ID", "id"), ("Job Run", "job_run_id"),
        ("Expected (min)", "expected_duration_minutes"),
        ("Actual (min)", "actual_duration_minutes"),
        ("Reason", "breach_reason"), ("Evaluated At", "evaluated_at"),
    ],
    "table_configs": [
        ("ID", "id"), ("Name", "name"), ("Source Type", "source_type"),
        ("Source Table", "source_table_name"), ("Dest Table", "destination_table_name"),
        ("Enabled", "is_enabled"), ("Created", "created_at"),
    ],
}

_TITLES = {
    "jobs": "Job Execution Report",
    "job_runs": "Job Run History Report",
    "errors": "Error Report",
    "audit": "Audit Trail Report",
    "sla_breaches": "SLA Compliance Report",
    "table_configs": "Table Configuration Report",
}
