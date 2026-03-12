"""
Application startup and health check handlers.
"""
from __future__ import annotations

import logging
import time
from typing import Dict, Any

from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from backend.database.engine import get_global_engine
from backend.database.session import get_global_session_factory

logger = logging.getLogger(__name__)


async def startup_handler() -> None:
    """
    Application startup handler with database connection verification and retry logic.
    """
    logger.info("Starting application startup sequence")
    
    max_attempts = 5
    delay = 1.0
    
    for attempt in range(max_attempts):
        try:
            logger.info(f"Database connection attempt {attempt + 1}/{max_attempts}")
            
            # Test database connection
            engine = get_global_engine()
            with engine.connect() as connection:
                # Simple query to verify connection
                result = connection.execute(text("SELECT 1"))
                result.fetchone()
            
            logger.info("Database connection successful")
            
            # Initialize session factory
            get_global_session_factory()
            logger.info("Session factory initialized")
            
            logger.info("Application startup completed successfully")
            return
            
        except Exception as e:
            logger.warning(
                f"Database connection attempt {attempt + 1} failed",
                extra={
                    "attempt": attempt + 1,
                    "max_attempts": max_attempts,
                    "error": str(e),
                    "error_type": type(e).__name__,
                }
            )
            
            if attempt == max_attempts - 1:
                logger.error("All database connection attempts failed, exiting")
                raise RuntimeError(f"Failed to connect to database after {max_attempts} attempts: {str(e)}")
            
            logger.info(f"Retrying in {delay} seconds...")
            time.sleep(delay)
            delay *= 2  # Exponential backoff


async def shutdown_handler() -> None:
    """
    Application shutdown handler.
    """
    logger.info("Starting application shutdown sequence")
    
    try:
        # Close database connections
        engine = get_global_engine()
        engine.dispose()
        logger.info("Database connections closed")
        
    except Exception as e:
        logger.error("Error during shutdown", extra={"error": str(e)})
    
    logger.info("Application shutdown completed")


async def health_check() -> Dict[str, Any]:
    """
    Health check function that verifies database connectivity.
    
    Returns:
        Dictionary with health status information
        
    Raises:
        Exception: If health check fails
    """
    logger.debug("Performing health check")
    
    health_status = {
        "status": "healthy",
        "timestamp": time.time(),
        "checks": {}
    }
    
    # Check database connectivity
    try:
        engine = get_global_engine()
        with engine.connect() as connection:
            start_time = time.time()
            result = connection.execute(text("SELECT 1"))
            result.fetchone()
            db_response_time = round((time.time() - start_time) * 1000, 2)
            
        health_status["checks"]["database"] = {
            "status": "healthy",
            "response_time_ms": db_response_time
        }
        
        logger.debug("Health check passed")
        
    except SQLAlchemyError as e:
        logger.error("Database health check failed", extra={"error": str(e)})
        health_status["status"] = "unhealthy"
        health_status["checks"]["database"] = {
            "status": "unhealthy",
            "error": str(e)
        }
        raise Exception("Database health check failed")
    
    except Exception as e:
        logger.error("Unexpected error during health check", extra={"error": str(e)})
        health_status["status"] = "unhealthy"
        health_status["checks"]["database"] = {
            "status": "unhealthy",
            "error": str(e)
        }
        raise
    
    return health_status