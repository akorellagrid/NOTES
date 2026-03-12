"""
Core application configuration using Pydantic BaseSettings.
"""
from __future__ import annotations

import os
from typing import Any

from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Database configuration
    database_url: str = Field(
        default="postgresql+psycopg2://postgres:postgres@localhost:5432/notes",
        env="DATABASE_URL",
        description="Database connection URL"
    )
    
    # Application configuration
    app_name: str = Field(
        default="Notes API",
        env="APP_NAME",
        description="Application name"
    )
    
    app_version: str = Field(
        default="1.0.0",
        env="APP_VERSION",
        description="Application version"
    )
    
    debug: bool = Field(
        default=False,
        env="DEBUG",
        description="Enable debug mode"
    )
    
    # Server configuration
    host: str = Field(
        default="0.0.0.0",
        env="HOST",
        description="Server host"
    )
    
    port: int = Field(
        default=8000,
        env="PORT",
        description="Server port"
    )
    
    # Database connection pool configuration
    db_pool_size: int = Field(
        default=5,
        env="DB_POOL_SIZE",
        description="Database connection pool size"
    )
    
    db_max_overflow: int = Field(
        default=10,
        env="DB_MAX_OVERFLOW",
        description="Database connection pool max overflow"
    )
    
    # Logging configuration
    log_level: str = Field(
        default="INFO",
        env="LOG_LEVEL",
        description="Logging level"
    )
    
    log_format: str = Field(
        default="json",
        env="LOG_FORMAT",
        description="Logging format (json or text)"
    )
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


# Global settings instance
_settings: Settings | None = None


def get_settings() -> Settings:
    """Get application settings instance."""
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings


def reload_settings() -> Settings:
    """Reload settings from environment (useful for testing)."""
    global _settings
    _settings = Settings()
    return _settings