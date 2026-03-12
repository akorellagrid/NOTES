"""
Pydantic schemas for notes with enhanced validation.
"""
from __future__ import annotations

from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, field_validator


class NoteCreate(BaseModel):
    """Request model for creating a note."""
    
    title: str = Field(
        min_length=1,
        max_length=200,
        description="Note title (1-200 characters)"
    )
    content: str = Field(
        min_length=1,
        max_length=10_000,
        description="Note content (1-10,000 characters)"
    )

    @field_validator("title", "content", mode="before")
    @classmethod
    def strip_whitespace(cls, value: Any) -> str:
        """Strip leading and trailing whitespace from string fields."""
        if isinstance(value, str):
            return value.strip()
        return value

    @field_validator("title", "content")
    @classmethod
    def validate_not_empty(cls, value: str) -> str:
        """Validate that string is not empty after stripping."""
        if not value:
            raise ValueError("Field cannot be empty")
        return value


class NoteUpdate(BaseModel):
    """Request model for updating a note."""
    
    title: str | None = Field(
        default=None,
        min_length=1,
        max_length=200,
        description="Updated note title"
    )
    content: str | None = Field(
        default=None,
        min_length=1,
        max_length=10_000,
        description="Updated note content"
    )

    @field_validator("title", "content", mode="before")
    @classmethod
    def strip_whitespace(cls, value: Any) -> str | None:
        """Strip leading and trailing whitespace from string fields."""
        if isinstance(value, str):
            return value.strip()
        return value

    @field_validator("title", "content")
    @classmethod
    def validate_not_empty(cls, value: str | None) -> str | None:
        """Validate that string is not empty after stripping."""
        if value is not None and not value:
            raise ValueError("Field cannot be empty")
        return value


class Note(BaseModel):
    """Response model for a note."""
    
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    content: str
    created_at: datetime
    updated_at: datetime