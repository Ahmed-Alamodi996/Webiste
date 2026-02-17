"""
Oracle connection pool using oracledb (thick/thin mode).
Used for data warehouse operations: export, load, MV refresh.
"""

import os
from contextlib import contextmanager
from typing import Any, Generator

import oracledb

from src.config.logging import get_logger
from src.config.settings import get_settings
from src.core.exceptions import OracleConnectionError

logger = get_logger(__name__)


class OraclePool:
    """Singleton Oracle connection pool with health monitoring."""

    _pool: oracledb.ConnectionPool | None = None

    @classmethod
    def initialize(cls) -> None:
        """Create the Oracle connection pool. Called once at startup."""
        if cls._pool is not None:
            return

        settings = get_settings()

        # Set NLS environment for UTF-8 support (Arabic + English)
        os.environ["NLS_LANG"] = "AMERICAN_AMERICA.AL32UTF8"

        try:
            cls._pool = oracledb.create_pool(
                user=settings.oracle_user,
                password=settings.oracle_password,
                dsn=settings.oracle_dsn,
                min=settings.oracle_pool_min,
                max=settings.oracle_pool_max,
                increment=settings.oracle_pool_increment,
                getmode=oracledb.POOL_GETMODE_TIMEDWAIT,
                wait_timeout=30,
                timeout=120,
                retry_count=3,
                retry_delay=2,
            )
            logger.info(
                "oracle_pool_created",
                min=settings.oracle_pool_min,
                max=settings.oracle_pool_max,
                dsn=settings.oracle_dsn,
            )
        except oracledb.Error as e:
            logger.error("oracle_pool_creation_failed", error=str(e))
            raise OracleConnectionError(
                "Failed to create Oracle connection pool",
                details={"dsn": settings.oracle_dsn},
            )

    @classmethod
    def get_pool(cls) -> oracledb.ConnectionPool:
        if cls._pool is None:
            cls.initialize()
        return cls._pool  # type: ignore[return-value]

    @classmethod
    @contextmanager
    def get_connection(cls) -> Generator[oracledb.Connection, None, None]:
        """Context manager for Oracle connections with automatic release."""
        pool = cls.get_pool()
        conn: oracledb.Connection | None = None
        try:
            conn = pool.acquire()
            yield conn
        except oracledb.Error as e:
            logger.error("oracle_connection_error", error=str(e))
            raise OracleConnectionError(
                "Oracle connection error", details={"error": str(e)}
            )
        finally:
            if conn is not None:
                try:
                    pool.release(conn)
                except oracledb.Error:
                    pass

    @classmethod
    def execute_query(
        cls, sql: str, params: dict[str, Any] | None = None
    ) -> list[dict[str, Any]]:
        """Execute a read query and return results as list of dicts."""
        with cls.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql, params or {})
                columns = [col[0] for col in cursor.description]
                return [dict(zip(columns, row)) for row in cursor.fetchall()]

    @classmethod
    def execute_dml(
        cls, sql: str, params: dict[str, Any] | None = None
    ) -> int:
        """Execute a DML statement and return rows affected."""
        with cls.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(sql, params or {})
                conn.commit()
                return cursor.rowcount

    @classmethod
    def execute_procedure(cls, name: str, args: list[Any]) -> None:
        """Execute a stored procedure (e.g., DBMS_MVIEW.REFRESH)."""
        with cls.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc(name, args)

    @classmethod
    def pool_stats(cls) -> dict[str, int]:
        """Return pool utilization metrics."""
        pool = cls.get_pool()
        return {
            "busy": pool.busy,
            "open": pool.opened,
            "min": pool.min,
            "max": pool.max,
        }

    @classmethod
    def close(cls) -> None:
        """Close the connection pool. Called at shutdown."""
        if cls._pool is not None:
            cls._pool.close(force=True)
            cls._pool = None
            logger.info("oracle_pool_closed")
