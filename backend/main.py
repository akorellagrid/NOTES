"""
Main FastAPI application with modular architecture.
"""
from __future__ import annotations

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.app.notes.api.routes import router as notes_router
from backend.core.config import get_settings
from backend.core.health import router as health_router
from backend.core.logging import setup_logging
from backend.core.startup import shutdown_handler, startup_handler
from backend.middleware.exception_handler import ExceptionHandlerMiddleware
from backend.middleware.request_logger import RequestLoggingMiddleware

# Setup logging first
setup_logging()
logger = logging.getLogger(__name__)

# Get settings
settings = get_settings()

# Create FastAPI app
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    debug=settings.debug,
    redirect_slashes=False,  # Disable automatic slash redirects
)

# Add middleware (order matters - last added is executed first)
app.add_middleware(ExceptionHandlerMiddleware)
app.add_middleware(RequestLoggingMiddleware)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add event handlers
app.add_event_handler("startup", startup_handler)
app.add_event_handler("shutdown", shutdown_handler)

# Include routers
app.include_router(health_router)
app.include_router(notes_router)

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint."""
    return {"message": f"{settings.app_name} - Production Grade Architecture"}


if __name__ == "__main__":
    import uvicorn
    
    logger.info("Starting application in development mode")
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level=settings.log_level.lower(),
    )