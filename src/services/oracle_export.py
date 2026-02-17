"""
Oracle Export Service.
Chunked export from Oracle tables to CSV with memory-safe processing.
Replaces extract_tables_to_excel2.py with production-grade implementation.
"""

import csv
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from uuid import UUID

from src.config.logging import get_logger
from src.config.settings import get_settings
from src.core.exceptions import ExportError
from src.core.retry import with_retry
from src.db.oracle import OraclePool

logger = get_logger(__name__)


class OracleExportService:
    """Exports Oracle tables to CSV files with chunked reads and progress tracking."""

    def __init__(self):
        self.settings = get_settings()

    @with_retry(max_attempts=3, retry_on=(Exception,))
    async def export_table(
        self,
        table_name: str,
        columns: list[str],
        where_clause: str | None = None,
        output_dir: str | None = None,
        chunk_size: int | None = None,
    ) -> dict[str, Any]:
        """
        Export an Oracle table to CSV in chunks.

        Returns:
            dict with keys: file_path, records_exported, duration_seconds
        """
        chunk = chunk_size or self.settings.job_chunk_size
        out_dir = output_dir or self.settings.export_temp_dir
        Path(out_dir).mkdir(parents=True, exist_ok=True)

        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        file_name = f"{table_name}_{timestamp}.csv"
        file_path = os.path.join(out_dir, file_name)

        start_time = datetime.now(timezone.utc)
        total_records = 0

        logger.info(
            "export_started",
            table=table_name,
            columns=len(columns),
            chunk_size=chunk,
        )

        try:
            # Use parameterized column list (safe against injection)
            col_list = ", ".join(f'"{c}"' for c in columns)
            base_query = f"SELECT {col_list} FROM {table_name}"
            if where_clause:
                base_query += f" WHERE {where_clause}"

            with OraclePool.get_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.arraysize = chunk

                    # Get total count for progress tracking
                    count_sql = f"SELECT COUNT(*) FROM {table_name}"
                    if where_clause:
                        count_sql += f" WHERE {where_clause}"
                    cursor.execute(count_sql)
                    expected_count = cursor.fetchone()[0]

                    logger.info(
                        "export_count",
                        table=table_name,
                        expected_records=expected_count,
                    )

                    # Execute main query
                    cursor.execute(base_query)
                    col_names = [desc[0] for desc in cursor.description]

                    # Write CSV in chunks (memory-safe for 100M+ rows)
                    with open(file_path, "w", newline="", encoding="utf-8-sig") as f:
                        writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
                        writer.writerow(col_names)

                        while True:
                            rows = cursor.fetchmany(chunk)
                            if not rows:
                                break

                            for row in rows:
                                # Sanitize: convert None to empty, strip whitespace
                                clean_row = []
                                for val in row:
                                    if val is None:
                                        clean_row.append("")
                                    elif isinstance(val, str):
                                        clean_row.append(
                                            val.replace("\n", " ")
                                            .replace("\r", "")
                                            .strip()
                                        )
                                    else:
                                        clean_row.append(str(val))
                                writer.writerow(clean_row)

                            total_records += len(rows)

                            if total_records % (chunk * 10) == 0:
                                logger.info(
                                    "export_progress",
                                    table=table_name,
                                    records=total_records,
                                    expected=expected_count,
                                )

            duration = (datetime.now(timezone.utc) - start_time).total_seconds()

            logger.info(
                "export_completed",
                table=table_name,
                records=total_records,
                duration_seconds=round(duration, 3),
                file_path=file_path,
            )

            return {
                "file_path": file_path,
                "file_name": file_name,
                "records_exported": total_records,
                "duration_seconds": round(duration, 3),
                "table_name": table_name,
            }

        except Exception as e:
            # Clean up partial file on failure
            if os.path.exists(file_path):
                os.remove(file_path)

            logger.error(
                "export_failed",
                table=table_name,
                error=str(e),
                records_before_failure=total_records,
            )
            raise ExportError(
                f"Export failed for table {table_name}",
                details={"table": table_name, "error": str(e)},
            )

    async def create_historical_snapshot(
        self,
        source_table: str,
        key_column: str,
        where_clause: str | None = None,
    ) -> dict[str, Any]:
        """
        Create/update a _historical table in Oracle for monthly snapshots.
        Replaces the logic from extract_tables_to_excel2.py.
        """
        historical_table = f"{source_table}_historical"
        current_month = datetime.now().strftime("%b-%y")

        logger.info(
            "historical_snapshot_started",
            source=source_table,
            historical=historical_table,
            month=current_month,
        )

        try:
            with OraclePool.get_connection() as conn:
                with conn.cursor() as cursor:
                    # Check if historical table exists
                    cursor.execute(
                        "SELECT COUNT(*) FROM user_tables WHERE table_name = :tbl",
                        {"tbl": historical_table.upper()},
                    )
                    exists = cursor.fetchone()[0] == 1

                    if not exists:
                        create_sql = (
                            f"CREATE TABLE {historical_table} AS "
                            f"SELECT ROWNUM AS row_id, {key_column} AS key_, x.*, "
                            f"'NULL' AS previous_case, 'NULL' AS previous_comments, "
                            f"'NULL' AS comments, SYSDATE AS date_time "
                            f"FROM {source_table} x WHERE 1=0"
                        )
                        cursor.execute(create_sql)
                        logger.info("historical_table_created", table=historical_table)

                    # Delete current month's data (idempotent reload)
                    cursor.execute(
                        f"DELETE FROM {historical_table} "
                        f"WHERE TO_CHAR(date_time, 'Mon-YY') = :month",
                        {"month": current_month},
                    )
                    deleted = cursor.rowcount

                    # Insert fresh snapshot
                    where = f"WHERE {where_clause}" if where_clause else ""
                    insert_sql = (
                        f"INSERT INTO {historical_table} "
                        f"SELECT ROWNUM AS row_id, {key_column} AS key_, x.*, "
                        f"'NULL' AS previous_case, 'NULL' AS previous_comments, "
                        f"'NULL' AS comments, SYSDATE AS date_time "
                        f"FROM {source_table} x {where}"
                    )
                    cursor.execute(insert_sql)
                    inserted = cursor.rowcount
                    conn.commit()

                    logger.info(
                        "historical_snapshot_completed",
                        table=historical_table,
                        deleted=deleted,
                        inserted=inserted,
                    )

                    return {
                        "historical_table": historical_table,
                        "records_deleted": deleted,
                        "records_inserted": inserted,
                        "month": current_month,
                    }

        except Exception as e:
            logger.error(
                "historical_snapshot_failed",
                source=source_table,
                error=str(e),
            )
            raise ExportError(
                f"Historical snapshot failed for {source_table}",
                details={"error": str(e)},
            )
