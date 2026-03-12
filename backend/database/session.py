"""
Database session factory configuration.
"""
from __future__ import annotations

import logging
from typing import Generator

from sqlalchemy.orm import Session, sessionmaker

from .engine import get_global_engine

logger = logging.getLogger(__name__)


def get_session_factory() -> sessionmaker[Session]:
    """Create session factory."""
    engine = get_global_engine()
    
    SessionLocal = sessionmaker(
        bind=engine,
        autocommit=False,
        autoflush=False,
        expire_on_commit=False,
    )
    
    return SessionLocal


def get_session() -> Session:
    """Create a new database session."""
    SessionLocal = get_session_factory()
    return SessionLocal()


# Global session factory
_session_factory: sessionmaker[Session] | None = None


def get_global_session_factory() -> sessionmaker[Session]:
    """Get global session factory instance."""
    global _session_factory
    if _session_factory is None:
        _session_factory = get_session_factory()
    return _session_factory