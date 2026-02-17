"""
Retry logic with exponential backoff.
Uses tenacity for production-grade retry patterns.
"""

import functools
from typing import Any, Callable, TypeVar

from tenacity import (
    RetryCallState,
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from src.config.logging import get_logger
from src.config.settings import get_settings

logger = get_logger(__name__)

F = TypeVar("F", bound=Callable[..., Any])


def _log_retry(retry_state: RetryCallState) -> None:
    """Log each retry attempt with structured context."""
    logger.warning(
        "retry_attempt",
        function=retry_state.fn.__name__ if retry_state.fn else "unknown",
        attempt=retry_state.attempt_number,
        wait_seconds=retry_state.next_action.sleep if retry_state.next_action else 0,
        error=str(retry_state.outcome.exception()) if retry_state.outcome and retry_state.outcome.failed else None,
    )


def with_retry(
    max_attempts: int | None = None,
    backoff_base: int | None = None,
    backoff_max: int = 300,
    retry_on: tuple[type[Exception], ...] = (Exception,),
) -> Callable[[F], F]:
    """
    Decorator for retry with exponential backoff.

    Usage:
        @with_retry(max_attempts=3, retry_on=(ConnectionError, TimeoutError))
        async def connect_to_oracle():
            ...
    """
    settings = get_settings()
    attempts = max_attempts or settings.job_max_retries
    base = backoff_base or settings.job_retry_backoff_base

    def decorator(func: F) -> F:
        @functools.wraps(func)
        @retry(
            stop=stop_after_attempt(attempts),
            wait=wait_exponential(multiplier=base, max=backoff_max),
            retry=retry_if_exception_type(retry_on),
            before_sleep=_log_retry,
            reraise=True,
        )
        async def async_wrapper(*args: Any, **kwargs: Any) -> Any:
            return await func(*args, **kwargs)

        @functools.wraps(func)
        @retry(
            stop=stop_after_attempt(attempts),
            wait=wait_exponential(multiplier=base, max=backoff_max),
            retry=retry_if_exception_type(retry_on),
            before_sleep=_log_retry,
            reraise=True,
        )
        def sync_wrapper(*args: Any, **kwargs: Any) -> Any:
            return func(*args, **kwargs)

        import asyncio

        if asyncio.iscoroutinefunction(func):
            return async_wrapper  # type: ignore[return-value]
        return sync_wrapper  # type: ignore[return-value]

    return decorator
