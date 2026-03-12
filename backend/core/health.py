"""
Health check API endpoint.
"""
from __future__ import annotations

import logging
from typing import Dict, Any

from fastapi import APIRouter, HTTPException, status

from backend.core.startup import health_check

logger = logging.getLogger(__name__)

router = APIRouter(tags=["health"])


@router.get("/health")
async def get_health() -> Dict[str, Any]:
    """
    Health check endpoint that verifies database connectivity.
    
    Returns:
        Health status information
        
    Raises:
        HTTPException: 500 if health check fails
    """
    logger.debug("Health check endpoint called")
    
    try:
        health_status = await health_check()
        return health_status
    except Exception as e:
        logger.error("Health check endpoint failed", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Health check failed"
        )