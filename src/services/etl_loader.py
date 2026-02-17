"""
ETL Loader Service.
Loads data from PostgreSQL/CSV/Excel into Oracle using SQL*Loader (bulk insert).
Replaces Loader_full_Newv2.py with production-grade implementation.
"""

import csv
import os
import subprocess
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import pandas as pd

from src.config.logging import get_logger
from src.config.settings import get_settings
from src.core.exceptions import LoadError
from src.core.retry import with_retry
from src.db.oracle import OraclePool

logger = get_logger(__name__)


class ETLLoaderService:
    """Loads data into Oracle from various sources using SQL*Loader bulk operations."""

    def __init__(self):
        self.settings = get_settings()

    def _generate_ctl_file(
        self,
        data_file: str,
        destination_table: str,
        destination_columns: list[str],
        file_name_constant: str,
        date_column: str | None = None,
        date_value: str | None = None,
        skip_rows: int = 1,
    ) -> str:
        """Generate a SQL*Loader control file. Returns path to the .ctl file."""
        Path(self.settings.ctl_dir).mkdir(parents=True, exist_ok=True)

        col_defs = ", ".join(f'"{col.strip()}"' for col in destination_columns)

        # Build constant columns
        constants = f'    "FILENAME" CONSTANT \'{file_name_constant}\''
        if date_column and date_value:
            constants += f',\n    "{date_column}" CONSTANT \'{date_value}\''

        ctl_content = f"""OPTIONS (SKIP={skip_rows})
LOAD DATA
INFILE '{data_file}'
INTO TABLE {destination_table}
APPEND
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    {col_defs},
{constants}
)
"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        ctl_path = os.path.join(
            self.settings.ctl_dir, f"{destination_table}_{timestamp}.ctl"
        )
        with open(ctl_path, "w") as f:
            f.write(ctl_content)

        logger.info("ctl_file_generated", path=ctl_path, table=destination_table)
        return ctl_path

    @with_retry(max_attempts=2, retry_on=(LoadError,))
    async def load_via_sqlldr(
        self,
        data_file: str,
        destination_table: str,
        destination_columns: list[str],
        file_name_constant: str,
        date_column: str | None = None,
        date_value: str | None = None,
        skip_rows: int = 1,
    ) -> dict[str, Any]:
        """
        Execute SQL*Loader for bulk data loading into Oracle.

        Returns:
            dict with keys: records_loaded, records_rejected, log_file, duration_seconds
        """
        start_time = datetime.now(timezone.utc)

        ctl_path = self._generate_ctl_file(
            data_file=data_file,
            destination_table=destination_table,
            destination_columns=destination_columns,
            file_name_constant=file_name_constant,
            date_column=date_column,
            date_value=date_value,
            skip_rows=skip_rows,
        )

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_dir = os.path.join(self.settings.backup_dir, "sqlldr_logs")
        Path(log_dir).mkdir(parents=True, exist_ok=True)
        log_file = os.path.join(log_dir, f"{destination_table}_{timestamp}.log")
        bad_file = os.path.join(log_dir, f"{destination_table}_{timestamp}.bad")

        # Build sqlldr command using env-based credentials (NOT in process list)
        # Write a temporary password file to avoid exposing creds
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".par", delete=False
        ) as par_file:
            par_file.write(
                f"userid={self.settings.oracle_user}/{self.settings.oracle_password}"
                f"@{self.settings.oracle_dsn}\n"
                f"control={ctl_path}\n"
                f"log={log_file}\n"
                f"bad={bad_file}\n"
                f"silent=feedback\n"
                f"direct=false\n"
                f"errors=1000\n"
            )
            par_path = par_file.name

        try:
            cmd = [self.settings.sqlldr_bin_path, f"parfile={par_path}"]

            logger.info(
                "sqlldr_started",
                table=destination_table,
                data_file=data_file,
            )

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=self.settings.job_default_timeout_seconds,
            )

            # Parse the log file for results
            records_loaded = 0
            records_rejected = 0

            if os.path.exists(log_file):
                with open(log_file, "r") as f:
                    for line in f:
                        if "Rows successfully loaded" in line:
                            parts = line.strip().split()
                            if parts:
                                try:
                                    records_loaded = int(parts[0])
                                except ValueError:
                                    pass
                        elif "Rows not loaded" in line and "due to data errors" in line:
                            parts = line.strip().split()
                            if parts:
                                try:
                                    records_rejected = int(parts[0])
                                except ValueError:
                                    pass

            duration = (datetime.now(timezone.utc) - start_time).total_seconds()

            if result.returncode not in (0, 2):  # 0=success, 2=warnings
                error_msg = result.stderr or "SQL*Loader returned non-zero exit code"
                logger.error(
                    "sqlldr_failed",
                    table=destination_table,
                    return_code=result.returncode,
                    error=error_msg,
                )
                raise LoadError(
                    f"SQL*Loader failed for {destination_table}",
                    details={
                        "return_code": result.returncode,
                        "log_file": log_file,
                    },
                )

            logger.info(
                "sqlldr_completed",
                table=destination_table,
                records_loaded=records_loaded,
                records_rejected=records_rejected,
                duration_seconds=round(duration, 3),
            )

            return {
                "records_loaded": records_loaded,
                "records_rejected": records_rejected,
                "log_file": log_file,
                "ctl_file": ctl_path,
                "duration_seconds": round(duration, 3),
                "destination_table": destination_table,
            }

        finally:
            # Clean up parameter file (contains credentials)
            if os.path.exists(par_path):
                os.remove(par_path)

    async def load_from_csv(
        self,
        csv_path: str,
        destination_table: str,
        source_columns: list[str],
        destination_columns: list[str],
        date_column: str | None = None,
        skip_rows: int = 0,
        backup_dir: str | None = None,
    ) -> dict[str, Any]:
        """
        Process a CSV file and load into Oracle.
        Handles data cleaning (remove commas in values, newlines, etc.)
        """
        logger.info("csv_load_started", file=csv_path, table=destination_table)

        try:
            df = pd.read_csv(csv_path, encoding="iso-8859-1", dtype=str, skiprows=skip_rows)

            # Select only the columns we need
            available_cols = [c for c in source_columns if c in df.columns]
            df = df[available_cols]

            # Clean data (same transformations as legacy but vectorized)
            for col in df.columns:
                df[col] = (
                    df[col]
                    .fillna("")
                    .astype(str)
                    .str.replace(",", "", regex=False)
                    .str.replace('"', "", regex=False)
                    .str.replace("\n", " ", regex=False)
                    .str.replace("  ", " ", regex=False)
                )

            records_count = len(df)

            # Write cleaned CSV to temp location
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            clean_file = os.path.join(
                self.settings.export_temp_dir,
                f"clean_{os.path.basename(csv_path)}_{timestamp}",
            )
            Path(self.settings.export_temp_dir).mkdir(parents=True, exist_ok=True)
            df.to_csv(clean_file, index=False, quotechar='"')

            # Load via SQL*Loader
            date_value = datetime.now().strftime("%Y-%m-%d") if date_column else None
            result = await self.load_via_sqlldr(
                data_file=clean_file,
                destination_table=destination_table,
                destination_columns=destination_columns,
                file_name_constant=os.path.basename(csv_path),
                date_column=date_column,
                date_value=date_value,
            )

            result["source_records"] = records_count
            result["source_file"] = csv_path

            # Backup original file if configured
            if backup_dir:
                Path(backup_dir).mkdir(parents=True, exist_ok=True)
                import shutil

                shutil.copy2(csv_path, os.path.join(backup_dir, os.path.basename(csv_path)))
                logger.info("file_backed_up", file=csv_path, backup_dir=backup_dir)

            return result

        except LoadError:
            raise
        except Exception as e:
            logger.error("csv_load_failed", file=csv_path, error=str(e))
            raise LoadError(
                f"CSV load failed for {csv_path}",
                details={"file": csv_path, "error": str(e)},
            )

    async def load_from_excel(
        self,
        excel_path: str,
        destination_table: str,
        source_columns: list[str],
        destination_columns: list[str],
        date_column: str | None = None,
        skip_rows: int = 0,
        backup_dir: str | None = None,
    ) -> dict[str, Any]:
        """Process an Excel file, convert to CSV, and load into Oracle."""
        logger.info("excel_load_started", file=excel_path, table=destination_table)

        try:
            df = pd.read_excel(excel_path, engine="openpyxl")

            # Select columns and clean
            available_cols = [c for c in source_columns if c in df.columns]
            df = df[available_cols]

            for col in df.columns:
                df[col] = (
                    df[col]
                    .fillna("")
                    .astype(str)
                    .str.replace(",", "", regex=False)
                    .str.replace('"', "", regex=False)
                    .str.replace("\n", " ", regex=False)
                    .str.replace("  ", " ", regex=False)
                    .str.slice(0, 4000)  # Oracle VARCHAR2 limit
                )

            records_count = len(df)

            # Convert to CSV for SQL*Loader
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            csv_file = os.path.join(
                self.settings.export_temp_dir,
                f"{os.path.splitext(os.path.basename(excel_path))[0]}_{timestamp}.csv",
            )
            Path(self.settings.export_temp_dir).mkdir(parents=True, exist_ok=True)
            df.to_csv(csv_file, index=False, quotechar='"')

            date_value = datetime.now().strftime("%Y-%m-%d") if date_column else None
            result = await self.load_via_sqlldr(
                data_file=csv_file,
                destination_table=destination_table,
                destination_columns=destination_columns,
                file_name_constant=os.path.basename(excel_path),
                date_column=date_column,
                date_value=date_value,
            )

            result["source_records"] = records_count
            result["source_file"] = excel_path

            if backup_dir:
                Path(backup_dir).mkdir(parents=True, exist_ok=True)
                import shutil

                shutil.copy2(
                    excel_path, os.path.join(backup_dir, os.path.basename(excel_path))
                )

            return result

        except LoadError:
            raise
        except Exception as e:
            logger.error("excel_load_failed", file=excel_path, error=str(e))
            raise LoadError(
                f"Excel load failed for {excel_path}",
                details={"file": excel_path, "error": str(e)},
            )
