"""
Redis connection for job queue, caching, and distributed locking.
"""

from typing import Any

import redis.asyncio as aioredis

from src.config.logging import get_logger
from src.config.settings import get_settings

logger = get_logger(__name__)


class RedisPool:
    """Singleton async Redis client."""

    _client: aioredis.Redis | None = None

    @classmethod
    def get_client(cls) -> aioredis.Redis:
        if cls._client is None:
            settings = get_settings()
            cls._client = aioredis.Redis(
                host=settings.redis_host,
                port=settings.redis_port,
                db=settings.redis_db,
                password=settings.redis_password or None,
                max_connections=settings.redis_max_connections,
                decode_responses=True,
                socket_connect_timeout=5,
                socket_timeout=10,
                retry_on_timeout=True,
            )
        return cls._client

    @classmethod
    async def close(cls) -> None:
        if cls._client is not None:
            await cls._client.close()
            cls._client = None


# --- Job Queue Operations ---

QUEUE_PREFIX = "ra:queue"
JOB_STATUS_PREFIX = "ra:job_status"


async def enqueue_job(job_type: str, payload: dict[str, Any]) -> str:
    """Push a job onto the Redis queue. Returns the message ID."""
    import json
    import uuid

    client = RedisPool.get_client()
    job_id = str(uuid.uuid4())
    message = json.dumps({"job_id": job_id, "type": job_type, "payload": payload})
    await client.lpush(f"{QUEUE_PREFIX}:{job_type}", message)
    await client.set(f"{JOB_STATUS_PREFIX}:{job_id}", "queued", ex=86400)
    logger.info("job_enqueued", job_id=job_id, job_type=job_type)
    return job_id


async def dequeue_job(job_type: str, timeout: int = 30) -> dict[str, Any] | None:
    """Blocking pop from the job queue. Returns parsed job or None on timeout."""
    import json

    client = RedisPool.get_client()
    result = await client.brpop(f"{QUEUE_PREFIX}:{job_type}", timeout=timeout)
    if result is None:
        return None
    _, raw = result
    return json.loads(raw)


async def update_job_status(job_id: str, status: str) -> None:
    """Update the cached job status in Redis."""
    client = RedisPool.get_client()
    await client.set(f"{JOB_STATUS_PREFIX}:{job_id}", status, ex=86400)


async def get_job_status_cached(job_id: str) -> str | None:
    """Get cached job status from Redis."""
    client = RedisPool.get_client()
    return await client.get(f"{JOB_STATUS_PREFIX}:{job_id}")


async def acquire_lock(name: str, timeout: int = 300) -> bool:
    """Acquire a distributed lock (e.g., to prevent duplicate MV refresh)."""
    client = RedisPool.get_client()
    return await client.set(f"ra:lock:{name}", "1", nx=True, ex=timeout)


async def release_lock(name: str) -> None:
    """Release a distributed lock."""
    client = RedisPool.get_client()
    await client.delete(f"ra:lock:{name}")
