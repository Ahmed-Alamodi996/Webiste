"""
YAML-based configuration management.

Provides a human-friendly alternative to managing JSON configs directly.
Supports loading, validating, and converting YAML config files for:
- Table configurations (ETL mappings)
- Connection profiles
- Job definitions

Usage:
    # CLI
    ra yaml import table_configs.yaml --type tables
    ra yaml export ./config_export/ --format yaml
    ra yaml validate my_config.yaml --type tables
    ra yaml template tables --output template.yaml

    # Programmatic
    from src.config.yaml_loader import load_config_file, validate_config
    items = load_config_file("table_configs.yaml")
    errors = validate_config(items, "tables")
"""

import json
from pathlib import Path
from typing import Any


def load_config_file(file_path: str) -> list[dict[str, Any]]:
    """Load configs from a YAML or JSON file.

    Supports:
    - .yaml / .yml files (requires PyYAML)
    - .json files
    - Multi-document YAML (separated by ---)
    """
    path = Path(file_path)
    content = path.read_text(encoding="utf-8")

    if path.suffix in (".yaml", ".yml"):
        try:
            import yaml

            docs = list(yaml.safe_load_all(content))
            # Flatten: handle both multi-doc and single-doc with list
            items = []
            for doc in docs:
                if doc is None:
                    continue
                if isinstance(doc, list):
                    items.extend(doc)
                elif isinstance(doc, dict):
                    items.append(doc)
            return items
        except ImportError:
            raise RuntimeError(
                "PyYAML is required for YAML support. "
                "Install it with: pip install pyyaml"
            )
    elif path.suffix == ".json":
        data = json.loads(content)
        return data if isinstance(data, list) else [data]
    else:
        # Try JSON first, then YAML
        try:
            data = json.loads(content)
            return data if isinstance(data, list) else [data]
        except json.JSONDecodeError:
            try:
                import yaml

                data = yaml.safe_load(content)
                if isinstance(data, list):
                    return data
                return [data] if data else []
            except ImportError:
                raise RuntimeError("Cannot parse file. Install PyYAML for YAML support.")


def validate_config(
    items: list[dict[str, Any]], config_type: str
) -> list[str]:
    """Validate config items against schema rules.

    Returns a list of error messages (empty = valid).
    """
    errors: list[str] = []
    validators = {
        "tables": _validate_table_config,
        "connections": _validate_connection,
        "jobs": _validate_job,
    }

    validator = validators.get(config_type)
    if not validator:
        return [f"Unknown config type: {config_type}"]

    for i, item in enumerate(items):
        item_errors = validator(item)
        for err in item_errors:
            errors.append(f"Item {i + 1}: {err}")

    return errors


def _validate_table_config(item: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required = ["name", "source_type", "source_table_name", "source_columns",
                 "destination_table_name", "destination_columns"]
    for field in required:
        if not item.get(field):
            errors.append(f"Missing required field: {field}")

    source_type = item.get("source_type", "")
    if source_type and source_type not in ("postgres", "csv", "excel", "oracle"):
        errors.append(f"Invalid source_type: '{source_type}' (must be postgres|csv|excel|oracle)")

    schedule_day = item.get("schedule_day")
    if schedule_day is not None:
        if not isinstance(schedule_day, int) or schedule_day < 1 or schedule_day > 31:
            errors.append(f"schedule_day must be 1-31, got: {schedule_day}")

    skip_rows = item.get("skip_rows", 0)
    if not isinstance(skip_rows, int) or skip_rows < 0:
        errors.append(f"skip_rows must be >= 0, got: {skip_rows}")

    return errors


def _validate_connection(item: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required = ["name", "db_type", "host", "port", "database_name", "username", "password_env_var"]
    for field in required:
        if not item.get(field):
            errors.append(f"Missing required field: {field}")

    db_type = item.get("db_type", "")
    if db_type and db_type not in ("oracle", "postgresql"):
        errors.append(f"Invalid db_type: '{db_type}' (must be oracle|postgresql)")

    port = item.get("port")
    if port is not None:
        if not isinstance(port, int) or port < 1 or port > 65535:
            errors.append(f"port must be 1-65535, got: {port}")

    return errors


def _validate_job(item: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required = ["name", "job_type"]
    for field in required:
        if not item.get(field):
            errors.append(f"Missing required field: {field}")

    job_type = item.get("job_type", "")
    if job_type and job_type not in ("export", "load", "refresh", "dependency_scan"):
        errors.append(f"Invalid job_type: '{job_type}' (must be export|load|refresh|dependency_scan)")

    retries = item.get("max_retries")
    if retries is not None:
        if not isinstance(retries, int) or retries < 0 or retries > 10:
            errors.append(f"max_retries must be 0-10, got: {retries}")

    timeout = item.get("timeout_seconds")
    if timeout is not None:
        if not isinstance(timeout, int) or timeout < 60 or timeout > 86400:
            errors.append(f"timeout_seconds must be 60-86400, got: {timeout}")

    return errors


def get_template(config_type: str) -> str:
    """Return a YAML template with examples and documentation."""
    templates = {
        "tables": _TABLE_CONFIG_TEMPLATE,
        "connections": _CONNECTION_TEMPLATE,
        "jobs": _JOB_TEMPLATE,
    }
    return templates.get(config_type, f"# Unknown config type: {config_type}")


# --- Templates ---

_TABLE_CONFIG_TEMPLATE = """# =============================================================================
# RA Platform - Table Configuration Template
# =============================================================================
# Define ETL mappings: source -> destination table configurations.
# Each entry maps a source (CSV, Excel, Oracle, or PostgreSQL) to an Oracle table.
#
# Usage:
#   ra yaml validate table_configs.yaml --type tables
#   ra yaml import table_configs.yaml --type tables
# =============================================================================

# --- Example 1: CSV file to Oracle ---
- name: "daily_subscriber_load"
  source_type: "csv"                    # csv | excel | oracle | postgres
  source_table_name: "subscribers.csv"  # filename or table name
  source_columns: "ID, NAME, PHONE, PLAN_TYPE, START_DATE"
  destination_table_name: "SUBSCRIBERS"
  destination_columns: "SUB_ID, SUB_NAME, PHONE_NUM, PLAN, ACTIVATION_DATE"
  where_condition: null                 # optional SQL WHERE clause
  date_format: "YYYY-MM-DD"            # date parsing format
  date_column: "START_DATE"            # column containing dates
  schedule_day: 1                      # day of month to run (1-31)
  skip_rows: 1                         # header rows to skip
  file_name_pattern: "subscribers_*.csv"
  file_extension_filter: ".csv"
  backup_folder: "/data/backups/subscribers"
  config_json:                         # extra config (JSONB)
    delimiter: ","
    encoding: "UTF-8"
    trim_spaces: true

# --- Example 2: Oracle to Oracle (table replication) ---
- name: "cdr_sync"
  source_type: "oracle"
  source_table_name: "CDR_RAW"
  source_columns: "CALL_ID, CALLER, CALLEE, DURATION, CALL_DATE"
  destination_table_name: "CDR_ARCHIVE"
  destination_columns: "CALL_ID, CALLER, CALLEE, DURATION, CALL_DATE"
  where_condition: "CALL_DATE >= TRUNC(SYSDATE) - 1"
  date_format: "YYYY-MM-DD HH24:MI:SS"
  date_column: "CALL_DATE"
  schedule_day: null                   # run on-demand only

# --- Example 3: Excel to Oracle ---
- name: "monthly_revenue_import"
  source_type: "excel"
  source_table_name: "revenue_report.xlsx"
  source_columns: "Region, Product, Revenue, Month"
  destination_table_name: "REVENUE_DATA"
  destination_columns: "REGION, PRODUCT, REVENUE_AMT, REPORT_MONTH"
  skip_rows: 2                         # skip title + header rows
  file_name_pattern: "revenue_*.xlsx"
  schedule_day: 5                      # run on 5th of each month
  config_json:
    sheet_name: "Summary"
"""

_CONNECTION_TEMPLATE = """# =============================================================================
# RA Platform - Connection Profile Template
# =============================================================================
# Define database connection profiles. Passwords are NEVER stored here.
# Instead, specify an environment variable name that holds the password.
#
# Usage:
#   ra yaml validate connections.yaml --type connections
#   ra yaml import connections.yaml --type connections
# =============================================================================

# --- Oracle Production ---
- name: "oracle_prod"
  db_type: "oracle"                    # oracle | postgresql
  host: "oracle-prod.example.com"
  port: 1521
  database_name: "ORCL"               # SID for Oracle
  username: "recon_prd"
  password_env_var: "ORACLE_PROD_PASSWORD"  # env var name (NOT the password!)
  extra_params:                        # optional driver-specific params
    encoding: "UTF-8"

# --- PostgreSQL Metadata ---
- name: "postgres_meta"
  db_type: "postgresql"
  host: "postgres.example.com"
  port: 5432
  database_name: "ra_metadata"
  username: "ra_admin"
  password_env_var: "POSTGRES_PASSWORD"

# --- Oracle UAT ---
- name: "oracle_uat"
  db_type: "oracle"
  host: "oracle-uat.example.com"
  port: 1521
  database_name: "UATDB"
  username: "recon_uat"
  password_env_var: "ORACLE_UAT_PASSWORD"
"""

_JOB_TEMPLATE = """# =============================================================================
# RA Platform - Job Definition Template
# =============================================================================
# Define automated jobs with schedules, retries, and configuration.
# Jobs are triggered either by cron schedule or manually via CLI/API.
#
# Job types: export, load, refresh, dependency_scan
#
# Usage:
#   ra yaml validate jobs.yaml --type jobs
#   ra yaml import jobs.yaml --type jobs
# =============================================================================

# --- Nightly Export Job ---
- name: "nightly_cdr_export"
  job_type: "export"                   # export | load | refresh | dependency_scan
  description: "Export CDR data nightly at 2 AM"
  schedule_cron: "0 2 * * *"          # cron: min hour day month weekday
  max_retries: 3                       # 0-10 retry attempts
  timeout_seconds: 3600                # 1 hour timeout
  config:                              # job-specific configuration
    table_name: "CDR_RAW"
    columns:
      - "CALL_ID"
      - "CALLER"
      - "CALLEE"
      - "DURATION"
    chunk_size: 100000
    where_clause: "CALL_DATE >= TRUNC(SYSDATE) - 1"

# --- Daily ETL Load Job ---
- name: "daily_subscriber_load"
  job_type: "load"
  description: "Load subscriber CSV files daily"
  schedule_cron: "30 3 * * *"         # 3:30 AM daily
  max_retries: 2
  timeout_seconds: 1800
  config:
    config_name: "daily_subscriber_load"  # references a table_config name
    source_directory: "/data/incoming/subscribers"

# --- MV Refresh Job ---
- name: "full_mv_refresh"
  job_type: "refresh"
  description: "Refresh all materialized views in dependency order"
  schedule_cron: "0 5 * * *"          # 5 AM daily
  max_retries: 1
  timeout_seconds: 7200                # 2 hour timeout
  config:
    parallel_workers: 4
    refresh_type: "COMPLETE"

# --- Dependency Scan (weekly) ---
- name: "weekly_dependency_scan"
  job_type: "dependency_scan"
  description: "Scan Oracle metadata for dependency graph updates"
  schedule_cron: "0 1 * * 0"          # Sunday 1 AM
  max_retries: 1
  timeout_seconds: 600
  config: {}
"""
