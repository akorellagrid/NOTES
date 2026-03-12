"""
Database engine configuration and creation.
"""
from __future__ import annotations

import logging
from typing import Any, Dict

from sqlalchemy import create_engine, Engine
from sqlalchemy.pool import QueuePool

from backend.core.config import get_settings

logger = logging.getLogger(__name__)


def get_engine() -> Engine:
    """Create and configure database engine."""
    settings = get_settings()
    
    # Engine configuration
    engine_config: Dict[str, Any] = {
        "url": settings.database_url,
        "pool_pre_ping": True,  # Verify connections before use
        "pool_recycle": 3600,   # Recycle connections after 1 hour
        "poolclass": QueuePool,
        "pool_size": settings.db_pool_size,
        "max_overflow": settings.db_max_overflow,
        "echo": settings.debug,  # Log SQL queries in debug mode
    }
    
    logger.info(
        "Creating database engine",
        extra={
            "database_url": settings.database_url.split("@")[-1],  # Hide credentials
            "pool_size": settings.db_pool_size,
            "max_overflow": settings.db_max_overflow,
        }
    )
    
    engine = create_engine(**engine_config)
    
    return engine


# Global engine instance
_engine: Engine | None = None


def get_global_engine() -> Engine:
    """Get global database engine instance."""
    global _engine
    if _engine is None:
        _engine = get_engine()
    return _engine