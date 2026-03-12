"""
Database dependency injection functions for FastAPI.
"""
from __future__ import annotations

import logging
from typing import Generator

from sqlalchemy.orm import Session

from .session import get_global_session_factory

logger = logging.getLogger(__name__)


def get_db() -> Generator[Session, None, None]:
    """
    Database session dependency for FastAPI routes.
    
    Yields:
        Session: Database session instance
    """
    SessionLocal = get_global_session_factory()
    db = SessionLocal()
    
    try:
        logger.debug("Created database session")
        yield db
    except Exception as e:
        logger.error("Database session error", extra={"error": str(e)})
        db.rollback()
        raise
    finally:
        logger.debug("Closing database session")
        db.close()