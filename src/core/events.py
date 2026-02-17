"""
Application lifecycle events: startup/shutdown hooks for connection pools.
"""

from src.config.logging import get_logger, setup_logging
from src.db.oracle import OraclePool
from src.db.postgres import async_engine
from src.db.redis import RedisPool

logger = get_logger(__name__)


async def on_startup() -> None:
    """Initialize all connections and resources on application start."""
    setup_logging()
    logger.info("platform_starting", event="startup")

    # Test PostgreSQL connection
    try:
        async with async_engine.connect() as conn:
            await conn.execute("SELECT 1")
        logger.info("postgres_connected")
    except Exception as e:
        logger.error("postgres_connection_failed", error=str(e))
        raise

    # Initialize Redis pool
    try:
        redis = RedisPool.get_client()
        await redis.ping()
        logger.info("redis_connected")
    except Exception as e:
        logger.warning("redis_connection_failed", error=str(e))

    # Initialize Oracle pool
    try:
        OraclePool.initialize()
        logger.info("oracle_pool_initialized")
    except Exception as e:
        logger.warning("oracle_pool_init_failed", error=str(e))

    logger.info("platform_started", event="startup_complete")


async def on_shutdown() -> None:
    """Gracefully close all connections on application shutdown."""
    logger.info("platform_shutting_down", event="shutdown")

    try:
        await async_engine.dispose()
        logger.info("postgres_pool_closed")
    except Exception as e:
        logger.error("postgres_close_error", error=str(e))

    try:
        await RedisPool.close()
        logger.info("redis_pool_closed")
    except Exception as e:
        logger.error("redis_close_error", error=str(e))

    try:
        OraclePool.close()
        logger.info("oracle_pool_closed")
    except Exception as e:
        logger.error("oracle_close_error", error=str(e))

    logger.info("platform_stopped", event="shutdown_complete")
