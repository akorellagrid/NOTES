"""
Exception handling middleware for FastAPI.
"""
from __future__ import annotations

import logging
import traceback
from typing import Any, Dict

from fastapi import HTTPException, Request, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)


class ExceptionHandlerMiddleware(BaseHTTPMiddleware):
    """Middleware to handle unhandled exceptions."""

    async def dispatch(self, request: Request, call_next) -> JSONResponse:
        """Process request and handle exceptions."""
        try:
            response = await call_next(request)
            return response
        except HTTPException:
            # Re-raise HTTP exceptions (they're handled by FastAPI)
            raise
        except Exception as e:
            # Log the full exception with stack trace
            logger.error(
                "Unhandled exception occurred",
                extra={
                    "method": request.method,
                    "path": str(request.url.path),
                    "query_params": str(request.url.query) if request.url.query else None,
                    "client_ip": request.client.host if request.client else None,
                    "error": str(e),
                    "error_type": type(e).__name__,
                    "traceback": traceback.format_exc(),
                }
            )
            
            # Return generic error response
            error_response: Dict[str, Any] = {
                "detail": "Internal server error"
            }
            
            # In debug mode, include more details
            from backend.core.config import get_settings
            settings = get_settings()
            if settings.debug:
                error_response.update({
                    "error_type": type(e).__name__,
                    "error_message": str(e),
                })
            
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=error_response
            )