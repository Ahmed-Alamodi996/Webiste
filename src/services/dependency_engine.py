"""
Dependency Graph Engine Service.
Analyzes Oracle view/MV dependencies via metadata + SQL parsing.
Performs topological sort to determine safe refresh order.
Replaces treevFinalv3.py with production-grade implementation.
"""

import re
from collections import defaultdict, deque
from typing import Any
from uuid import UUID, uuid4

from src.config.logging import get_logger
from src.core.exceptions import DependencyError
from src.db.oracle import OraclePool

logger = get_logger(__name__)


class DependencyEngineService:
    """Analyzes and manages Oracle view/MV dependency graphs."""

    def __init__(self):
        self._graph: dict[str, set[str]] = defaultdict(set)
        self._object_types: dict[str, str] = {}

    async def scan_dependencies(self, schema_owner: str = "RECON_PRD") -> dict[str, Any]:
        """
        Full dependency scan: queries Oracle metadata + parses SQL definitions.
        Returns scan results with topological ordering.
        """
        scan_id = uuid4()
        logger.info("dependency_scan_started", scan_id=str(scan_id), schema=schema_owner)

        try:
            # Step 1: Get all views and materialized views
            all_objects = self._get_all_objects(schema_owner)
            object_names = {name for name, _ in all_objects}

            for name, obj_type in all_objects:
                self._object_types[name] = obj_type

            logger.info("objects_found", count=len(all_objects))

            # Step 2: Get dependencies from Oracle metadata (all_dependencies)
            metadata_deps = self._get_metadata_dependencies(schema_owner)
            for dependent, referenced in metadata_deps:
                if dependent != referenced:
                    self._graph[dependent].add(referenced)

            logger.info("metadata_dependencies", count=len(metadata_deps))

            # Step 3: Parse SQL definitions for additional dependencies
            mview_queries = self._get_mview_definitions(schema_owner)
            view_definitions = self._get_view_definitions(schema_owner)

            sql_dep_count = 0
            for obj_name, sql_text in {**mview_queries, **view_definitions}.items():
                if sql_text:
                    deps = self._extract_deps_from_sql(sql_text, object_names)
                    deps.discard(obj_name)  # Remove self-dependency
                    if deps:
                        self._graph[obj_name].update(deps)
                        sql_dep_count += len(deps)

            logger.info("sql_parsed_dependencies", count=sql_dep_count)

            # Step 4: Topological sort
            sorted_order, levels = self._topological_sort(object_names)

            logger.info(
                "dependency_scan_completed",
                scan_id=str(scan_id),
                objects=len(all_objects),
                levels=max(levels.values()) + 1 if levels else 0,
            )

            return {
                "scan_id": str(scan_id),
                "total_objects": len(all_objects),
                "total_edges": sum(len(deps) for deps in self._graph.values()),
                "topological_levels": max(levels.values()) + 1 if levels else 0,
                "sorted_order": sorted_order,
                "levels": levels,
                "graph": {k: list(v) for k, v in self._graph.items()},
                "object_types": self._object_types,
            }

        except Exception as e:
            logger.error("dependency_scan_failed", error=str(e))
            raise DependencyError(
                "Dependency scan failed", details={"error": str(e)}
            )

    def _get_all_objects(self, schema_owner: str) -> list[tuple[str, str]]:
        """Get all views and materialized views from Oracle."""
        sql = """
            SELECT object_name, object_type
            FROM all_objects
            WHERE object_type IN ('VIEW', 'MATERIALIZED VIEW')
              AND owner = :owner
        """
        rows = OraclePool.execute_query(sql, {"owner": schema_owner})
        return [(r["OBJECT_NAME"], r["OBJECT_TYPE"]) for r in rows]

    def _get_metadata_dependencies(
        self, schema_owner: str
    ) -> list[tuple[str, str]]:
        """Get dependency edges from Oracle all_dependencies."""
        sql = """
            SELECT d.name AS dependent, d.referenced_name AS referenced
            FROM all_dependencies d
            JOIN all_objects o ON d.name = o.object_name AND d.owner = o.owner
            WHERE o.object_type IN ('VIEW', 'MATERIALIZED VIEW')
              AND o.owner = :owner
              AND d.referenced_owner = :owner
              AND d.referenced_name IN (
                  SELECT object_name FROM all_objects
                  WHERE object_type IN ('VIEW', 'MATERIALIZED VIEW')
                    AND owner = :owner
              )
              AND d.name != d.referenced_name
        """
        rows = OraclePool.execute_query(sql, {"owner": schema_owner})
        return [(r["DEPENDENT"], r["REFERENCED"]) for r in rows]

    def _get_mview_definitions(self, schema_owner: str) -> dict[str, str]:
        """Get materialized view query text for SQL-based dependency extraction."""
        sql = """
            SELECT mview_name, query
            FROM all_mviews
            WHERE owner = :owner
        """
        rows = OraclePool.execute_query(sql, {"owner": schema_owner})
        return {r["MVIEW_NAME"]: r["QUERY"] or "" for r in rows}

    def _get_view_definitions(self, schema_owner: str) -> dict[str, str]:
        """Get view definitions for SQL-based dependency extraction."""
        sql = """
            SELECT view_name, text
            FROM all_views
            WHERE owner = :owner
        """
        rows = OraclePool.execute_query(sql, {"owner": schema_owner})
        return {r["VIEW_NAME"]: r["TEXT"] or "" for r in rows}

    def _extract_deps_from_sql(
        self, sql_text: str, known_objects: set[str]
    ) -> set[str]:
        """Extract referenced object names from SQL text."""
        # Remove string literals and comments
        cleaned = re.sub(r"'[^']*'", "", sql_text.upper())
        cleaned = re.sub(r"--.*$", "", cleaned, flags=re.MULTILINE)
        cleaned = re.sub(r"/\*.*?\*/", "", cleaned, flags=re.DOTALL)

        found = set()
        for obj_name in known_objects:
            pattern = r"\b" + re.escape(obj_name.upper()) + r"\b"
            if re.search(pattern, cleaned):
                found.add(obj_name)

        return found

    def _topological_sort(
        self, all_objects: set[str]
    ) -> tuple[list[str], dict[str, int]]:
        """
        Topological sort with level assignment for parallel refresh.
        Objects at the same level can be refreshed in parallel.
        """
        # Calculate in-degrees
        in_degree: dict[str, int] = {obj: 0 for obj in all_objects}
        for deps in self._graph.values():
            for dep in deps:
                if dep in in_degree:
                    in_degree[dep] += 1

        # BFS-based topological sort with level tracking
        queue = deque()
        levels: dict[str, int] = {}

        for obj in in_degree:
            if in_degree[obj] == 0:
                queue.append(obj)
                levels[obj] = 0

        sorted_order: list[str] = []
        while queue:
            item = queue.popleft()
            sorted_order.append(item)

            if item in self._graph:
                for dependent in self._graph[item]:
                    if dependent in in_degree:
                        in_degree[dependent] -= 1
                        levels[dependent] = max(
                            levels.get(dependent, 0), levels[item] + 1
                        )
                        if in_degree[dependent] == 0:
                            queue.append(dependent)

        # Handle cycles: add remaining objects at the highest level
        remaining = all_objects - set(sorted_order)
        if remaining:
            max_level = max(levels.values()) + 1 if levels else 0
            logger.warning(
                "cyclic_dependencies_detected",
                count=len(remaining),
                objects=list(remaining)[:10],
            )
            for obj in remaining:
                sorted_order.append(obj)
                levels[obj] = max_level

        return sorted_order, levels

    def get_refresh_plan(
        self, sorted_order: list[str], levels: dict[str, int]
    ) -> list[list[str]]:
        """
        Group objects by topological level for parallel refresh.
        Returns list of lists: each inner list can be refreshed concurrently.
        """
        if not levels:
            return []

        max_level = max(levels.values())
        plan: list[list[str]] = [[] for _ in range(max_level + 1)]

        for obj in sorted_order:
            level = levels.get(obj, max_level)
            plan[level].append(obj)

        # Filter to only MVs (views don't need refreshing)
        mv_plan = []
        for level_objects in plan:
            mvs = [
                obj
                for obj in level_objects
                if self._object_types.get(obj) == "MATERIALIZED VIEW"
            ]
            if mvs:
                mv_plan.append(mvs)

        return mv_plan
