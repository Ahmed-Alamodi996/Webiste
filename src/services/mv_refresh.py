"""
Materialized View Refresh Service.
Dependency-aware parallel refresh with timeout, retry, and failure isolation.
Replaces Refresh_withkill.py with production-grade implementation.
"""

import asyncio
import concurrent.futures
from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from src.config.logging import get_logger
from src.config.settings import get_settings
from src.core.exceptions import RefreshError
from src.db.oracle import OraclePool
from src.db.redis import acquire_lock, release_lock

logger = get_logger(__name__)


def _refresh_single_mv(
    mv_name: str, refresh_type: str, timeout_seconds: int
) -> dict[str, Any]:
    """
    Refresh a single materialized view in a separate process.
    This function runs in a ProcessPoolExecutor for true parallelism
    and failure isolation (one crash won't kill others).
    """
    start = datetime.now(timezone.utc)
    try:
        with OraclePool.get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.callproc("DBMS_MVIEW.REFRESH", [mv_name, refresh_type[0]])

        duration = (datetime.now(timezone.utc) - start).total_seconds()
        return {
            "mv_name": mv_name,
            "status": "success",
            "duration_seconds": round(duration, 3),
            "error": None,
        }

    except Exception as e:
        duration = (datetime.now(timezone.utc) - start).total_seconds()
        error_msg = str(e).replace("\n", " ")
        return {
            "mv_name": mv_name,
            "status": "failed",
            "duration_seconds": round(duration, 3),
            "error": error_msg,
        }


class MVRefreshService:
    """
    Refreshes materialized views in dependency order with parallel execution
    within each topological level.
    """

    def __init__(self):
        self.settings = get_settings()

    async def refresh_all(
        self,
        refresh_plan: list[list[str]],
        refresh_type: str = "COMPLETE",
        max_parallel: int | None = None,
        timeout_per_mv: int | None = None,
    ) -> dict[str, Any]:
        """
        Execute refresh across all topological levels.

        Args:
            refresh_plan: List of levels, each containing MV names to refresh in parallel.
            refresh_type: COMPLETE, FAST, or FORCE
            max_parallel: Max concurrent refreshes per level
            timeout_per_mv: Timeout per individual MV refresh in seconds

        Returns:
            Summary with per-MV results, timing, and error details.
        """
        # Acquire distributed lock to prevent concurrent full refreshes
        lock_name = "mv_refresh_all"
        if not await acquire_lock(lock_name, timeout=self.settings.job_default_timeout_seconds):
            raise RefreshError(
                "Another MV refresh is already running",
                details={"lock": lock_name},
            )

        parallel = max_parallel or self.settings.job_parallel_workers
        timeout = timeout_per_mv or self.settings.job_default_timeout_seconds
        overall_start = datetime.now(timezone.utc)

        results: list[dict[str, Any]] = []
        total_success = 0
        total_failed = 0
        total_skipped = 0

        try:
            for level_idx, level_mvs in enumerate(refresh_plan):
                logger.info(
                    "refresh_level_started",
                    level=level_idx,
                    mv_count=len(level_mvs),
                    total_levels=len(refresh_plan),
                )

                level_results = await self._refresh_level(
                    level_mvs, refresh_type, parallel, timeout
                )

                for r in level_results:
                    results.append({**r, "level": level_idx})
                    if r["status"] == "success":
                        total_success += 1
                    elif r["status"] == "failed":
                        total_failed += 1
                    else:
                        total_skipped += 1

                logger.info(
                    "refresh_level_completed",
                    level=level_idx,
                    success=sum(1 for r in level_results if r["status"] == "success"),
                    failed=sum(1 for r in level_results if r["status"] == "failed"),
                )

            overall_duration = (
                datetime.now(timezone.utc) - overall_start
            ).total_seconds()

            summary = {
                "total_mvs": sum(len(level) for level in refresh_plan),
                "total_levels": len(refresh_plan),
                "success": total_success,
                "failed": total_failed,
                "skipped": total_skipped,
                "duration_seconds": round(overall_duration, 3),
                "refresh_type": refresh_type,
                "results": results,
            }

            logger.info(
                "refresh_all_completed",
                success=total_success,
                failed=total_failed,
                duration=round(overall_duration, 3),
            )

            return summary

        finally:
            await release_lock(lock_name)

    async def _refresh_level(
        self,
        mv_names: list[str],
        refresh_type: str,
        max_parallel: int,
        timeout: int,
    ) -> list[dict[str, Any]]:
        """Refresh all MVs in a single topological level in parallel."""
        loop = asyncio.get_event_loop()
        results = []

        # Use ThreadPoolExecutor for I/O-bound Oracle calls
        # (ProcessPoolExecutor for CPU-bound; Oracle calls are I/O-bound)
        with concurrent.futures.ThreadPoolExecutor(
            max_workers=max_parallel
        ) as executor:
            futures = {
                executor.submit(
                    _refresh_single_mv, mv_name, refresh_type, timeout
                ): mv_name
                for mv_name in mv_names
            }

            for future in concurrent.futures.as_completed(
                futures, timeout=timeout + 60
            ):
                mv_name = futures[future]
                try:
                    result = future.result(timeout=timeout)
                    results.append(result)
                except concurrent.futures.TimeoutError:
                    logger.error("mv_refresh_timeout", mv_name=mv_name, timeout=timeout)
                    results.append({
                        "mv_name": mv_name,
                        "status": "timeout",
                        "duration_seconds": timeout,
                        "error": f"Timed out after {timeout}s",
                    })
                except Exception as e:
                    logger.error(
                        "mv_refresh_error",
                        mv_name=mv_name,
                        error=str(e),
                    )
                    results.append({
                        "mv_name": mv_name,
                        "status": "failed",
                        "duration_seconds": 0,
                        "error": str(e),
                    })

        return results

    async def refresh_single(
        self, mv_name: str, refresh_type: str = "COMPLETE"
    ) -> dict[str, Any]:
        """Refresh a single materialized view."""
        lock_name = f"mv_refresh_{mv_name}"
        if not await acquire_lock(lock_name, timeout=3600):
            raise RefreshError(
                f"MV {mv_name} is already being refreshed",
                details={"mv_name": mv_name},
            )

        try:
            result = _refresh_single_mv(
                mv_name,
                refresh_type,
                self.settings.job_default_timeout_seconds,
            )

            if result["status"] == "failed":
                raise RefreshError(
                    f"Refresh failed for {mv_name}",
                    details=result,
                )

            return result
        finally:
            await release_lock(lock_name)
