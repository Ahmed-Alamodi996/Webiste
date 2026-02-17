"""
Centralized configuration using Pydantic Settings.
All values sourced from environment variables - zero hardcoded secrets.
"""

from functools import lru_cache
from typing import Literal

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # --- Environment ---
    environment: Literal["dev", "uat", "prod", "test"] = "dev"
    debug: bool = False
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = "INFO"
    app_name: str = "ra-platform"
    app_version: str = "1.0.0"

    # --- API ---
    api_host: str = "0.0.0.0"
    api_port: int = 8000
    api_workers: int = 4
    api_reload: bool = False

    # --- PostgreSQL ---
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    postgres_db: str = "ra_metadata"
    postgres_user: str = "ra_admin"
    postgres_password: str = Field(..., min_length=1)
    postgres_pool_size: int = 20
    postgres_max_overflow: int = 10
    postgres_echo: bool = False

    @property
    def postgres_dsn(self) -> str:
        return (
            f"postgresql+asyncpg://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )

    @property
    def postgres_dsn_sync(self) -> str:
        return (
            f"postgresql+psycopg2://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )

    # --- Oracle ---
    oracle_host: str = "localhost"
    oracle_port: int = 1521
    oracle_sid: str = "ORCL"
    oracle_user: str = "recon_prd"
    oracle_password: str = Field(..., min_length=1)
    oracle_pool_min: int = 2
    oracle_pool_max: int = 10
    oracle_pool_increment: int = 1
    oracle_home: str = "/opt/oracle/instantclient"

    @property
    def oracle_dsn(self) -> str:
        return f"{self.oracle_host}:{self.oracle_port}/{self.oracle_sid}"

    # --- Redis ---
    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_db: int = 0
    redis_password: str = ""
    redis_max_connections: int = 50

    @property
    def redis_url(self) -> str:
        auth = f":{self.redis_password}@" if self.redis_password else ""
        return f"redis://{auth}{self.redis_host}:{self.redis_port}/{self.redis_db}"

    # --- JWT ---
    jwt_secret_key: str = Field(..., min_length=16)
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 60
    jwt_refresh_token_expire_days: int = 7

    # --- Job Configuration ---
    job_default_timeout_seconds: int = 3600
    job_max_retries: int = 3
    job_retry_backoff_base: int = 2
    job_chunk_size: int = 50000
    job_parallel_workers: int = 4

    # --- SLA ---
    sla_export_max_duration_minutes: int = 30
    sla_load_max_duration_minutes: int = 60
    sla_refresh_max_duration_minutes: int = 120
    sla_breach_alert_enabled: bool = True

    # --- Paths ---
    export_temp_dir: str = "/tmp/ra-exports"
    backup_dir: str = "/tmp/ra-backups"
    ctl_dir: str = "/tmp/ra-ctl"
    sqlldr_bin_path: str = "/opt/oracle/instantclient/sqlldr"

    @field_validator("log_level", mode="before")
    @classmethod
    def uppercase_log_level(cls, v: str) -> str:
        return v.upper()

    @property
    def is_production(self) -> bool:
        return self.environment == "prod"

    @property
    def is_testing(self) -> bool:
        return self.environment == "test"


@lru_cache()
def get_settings() -> Settings:
    """Cached singleton settings instance."""
    return Settings()
