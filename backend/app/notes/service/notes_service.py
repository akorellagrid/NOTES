"""
Business logic service for notes.
"""
from __future__ import annotations

import logging
from typing import List

from sqlalchemy.orm import Session

from backend.app.notes.crud import notes_crud
from backend.app.notes.model.models import NoteModel
from backend.app.notes.schema.schemas import NoteCreate, NoteUpdate

logger = logging.getLogger(__name__)


class NoteNotFoundError(Exception):
    """Raised when a note is not found."""
    
    def __init__(self, note_id: int):
        self.note_id = note_id
        super().__init__(f"Note with id {note_id} not found")


class NoteValidationError(Exception):
    """Raised when note validation fails."""
    pass


def create_note(db: Session, note_data: NoteCreate) -> NoteModel:
    """
    Create a new note with business logic validation.
    
    Args:
        db: Database session
        note_data: Note creation data
        
    Returns:
        Created note model
        
    Raises:
        NoteValidationError: If validation fails
    """
    logger.info("Creating note via service", extra={"title": note_data.title[:50]})
    
    # Additional business logic can be added here
    # For example: duplicate title checking, content analysis, etc.
    
    try:
        note = notes_crud.create_note(
            db=db,
            title=note_data.title,
            content=note_data.content
        )
        
        logger.info("Note created via service", extra={"note_id": note.id})
        return note
        
    except Exception as e:
        logger.error("Failed to create note", extra={"error": str(e)})
        raise NoteValidationError(f"Failed to create note: {str(e)}")


def get_note(db: Session, note_id: int) -> NoteModel:
    """
    Retrieve a note by ID with business logic.
    
    Args:
        db: Database session
        note_id: Note ID
        
    Returns:
        Note model
        
    Raises:
        NoteNotFoundError: If note is not found
    """
    logger.debug("Getting note via service", extra={"note_id": note_id})
    
    note = notes_crud.get_note(db=db, note_id=note_id)
    
    if not note:
        logger.warning("Note not found via service", extra={"note_id": note_id})
        raise NoteNotFoundError(note_id)
    
    return note


def list_notes(db: Session, skip: int = 0, limit: int = 100) -> List[NoteModel]:
    """
    List notes with business logic and pagination.
    
    Args:
        db: Database session
        skip: Number of records to skip
        limit: Maximum number of records to return
        
    Returns:
        List of note models
    """
    logger.debug("Listing notes via service", extra={"skip": skip, "limit": limit})
    
    # Validate pagination parameters
    if skip < 0:
        skip = 0
    if limit <= 0 or limit > 1000:  # Prevent excessive queries
        limit = 100
    
    notes = notes_crud.get_notes(db=db, skip=skip, limit=limit)
    
    logger.debug("Notes listed via service", extra={"count": len(notes)})
    return notes


def update_note(db: Session, note_id: int, note_data: NoteUpdate) -> NoteModel:
    """
    Update a note with business logic validation.
    
    Args:
        db: Database session
        note_id: Note ID
        note_data: Note update data
        
    Returns:
        Updated note model
        
    Raises:
        NoteNotFoundError: If note is not found
        NoteValidationError: If validation fails
    """
    logger.info("Updating note via service", extra={"note_id": note_id})
    
    # Check if note exists first
    existing_note = notes_crud.get_note(db=db, note_id=note_id)
    if not existing_note:
        logger.warning("Note not found for update via service", extra={"note_id": note_id})
        raise NoteNotFoundError(note_id)
    
    # Validate that at least one field is being updated
    if note_data.title is None and note_data.content is None:
        logger.warning("No fields to update", extra={"note_id": note_id})
        raise NoteValidationError("At least one field must be provided for update")
    
    try:
        updated_note = notes_crud.update_note(
            db=db,
            note_id=note_id,
            title=note_data.title,
            content=note_data.content
        )
        
        if not updated_note:
            # This shouldn't happen since we checked existence above
            raise NoteNotFoundError(note_id)
        
        logger.info("Note updated via service", extra={"note_id": note_id})
        return updated_note
        
    except Exception as e:
        if isinstance(e, NoteNotFoundError):
            raise
        logger.error("Failed to update note", extra={"note_id": note_id, "error": str(e)})
        raise NoteValidationError(f"Failed to update note: {str(e)}")


def delete_note(db: Session, note_id: int) -> None:
    """
    Delete a note with business logic.
    
    Args:
        db: Database session
        note_id: Note ID
        
    Raises:
        NoteNotFoundError: If note is not found
    """
    logger.info("Deleting note via service", extra={"note_id": note_id})
    
    # Check if note exists first
    existing_note = notes_crud.get_note(db=db, note_id=note_id)
    if not existing_note:
        logger.warning("Note not found for deletion via service", extra={"note_id": note_id})
        raise NoteNotFoundError(note_id)
    
    # Additional business logic can be added here
    # For example: check permissions, create audit log, etc.
    
    success = notes_crud.delete_note(db=db, note_id=note_id)
    
    if not success:
        # This shouldn't happen since we checked existence above
        raise NoteNotFoundError(note_id)
    
    logger.info("Note deleted via service", extra={"note_id": note_id})