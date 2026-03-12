"""
Request logging middleware for FastAPI.
"""
from __future__ import annotations

import logging
import time
from typing import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log HTTP requests and responses."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """Process request and log details."""
        start_time = time.time()
        
        # Log incoming request
        logger.info(
            "Incoming request",
            extra={
                "method": request.method,
                "path": str(request.url.path),
                "query_params": str(request.url.query) if request.url.query else None,
                "client_ip": request.client.host if request.client else None,
                "user_agent": request.headers.get("user-agent"),
                "timestamp": start_time,
            }
        )
        
        # Process request
        try:
            response = await call_next(request)
        except Exception as e:
            # Log error and re-raise
            duration = time.time() - start_time
            logger.error(
                "Request failed with exception",
                extra={
                    "method": request.method,
                    "path": str(request.url.path),
                    "duration_ms": round(duration * 1000, 2),
                    "error": str(e),
                    "error_type": type(e).__name__,
                }
            )
            raise
        
        # Log outgoing response
        duration = time.time() - start_time
        logger.info(
            "Outgoing response",
            extra={
                "method": request.method,
                "path": str(request.url.path),
                "status_code": response.status_code,
                "duration_ms": round(duration * 1000, 2),
                "response_size": response.headers.get("content-length"),
            }
        )
        
        # Add timing header
        response.headers["X-Process-Time"] = str(round(duration * 1000, 2))
        
        return response