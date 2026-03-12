"""
CRUD operations for notes.
"""
from __future__ import annotations

import logging
from typing import List

from sqlalchemy.orm import Session

from backend.app.notes.model.models import NoteModel

logger = logging.getLogger(__name__)


def create_note(db: Session, title: str, content: str) -> NoteModel:
    """
    Create a new note.
    
    Args:
        db: Database session
        title: Note title
        content: Note content
        
    Returns:
        Created note model
    """
    logger.info("Creating new note", extra={"title": title[:50]})
    
    note = NoteModel(title=title, content=content)
    db.add(note)
    db.commit()
    db.refresh(note)
    
    logger.info("Note created successfully", extra={"note_id": note.id})
    return note


def get_note(db: Session, note_id: int) -> NoteModel | None:
    """
    Retrieve a note by ID.
    
    Args:
        db: Database session
        note_id: Note ID
        
    Returns:
        Note model or None if not found
    """
    logger.debug("Retrieving note", extra={"note_id": note_id})
    
    note = db.query(NoteModel).filter(NoteModel.id == note_id).first()
    
    if note:
        logger.debug("Note found", extra={"note_id": note_id})
    else:
        logger.debug("Note not found", extra={"note_id": note_id})
    
    return note


def get_notes(db: Session, skip: int = 0, limit: int = 100) -> List[NoteModel]:
    """
    Retrieve multiple notes with pagination.
    
    Args:
        db: Database session
        skip: Number of records to skip
        limit: Maximum number of records to return
        
    Returns:
        List of note models
    """
    logger.debug("Retrieving notes", extra={"skip": skip, "limit": limit})
    
    notes = (
        db.query(NoteModel)
        .order_by(NoteModel.id)
        .offset(skip)
        .limit(limit)
        .all()
    )
    
    logger.debug("Notes retrieved", extra={"count": len(notes)})
    return notes


def update_note(
    db: Session, 
    note_id: int, 
    title: str | None = None, 
    content: str | None = None
) -> NoteModel | None:
    """
    Update a note.
    
    Args:
        db: Database session
        note_id: Note ID
        title: New title (optional)
        content: New content (optional)
        
    Returns:
        Updated note model or None if not found
    """
    logger.info("Updating note", extra={"note_id": note_id})
    
    note = db.query(NoteModel).filter(NoteModel.id == note_id).first()
    
    if not note:
        logger.warning("Note not found for update", extra={"note_id": note_id})
        return None
    
    # Update fields if provided
    if title is not None:
        note.title = title
    if content is not None:
        note.content = content
    
    db.commit()
    db.refresh(note)
    
    logger.info("Note updated successfully", extra={"note_id": note_id})
    return note


def delete_note(db: Session, note_id: int) -> bool:
    """
    Delete a note.
    
    Args:
        db: Database session
        note_id: Note ID
        
    Returns:
        True if deleted, False if not found
    """
    logger.info("Deleting note", extra={"note_id": note_id})
    
    note = db.query(NoteModel).filter(NoteModel.id == note_id).first()
    
    if not note:
        logger.warning("Note not found for deletion", extra={"note_id": note_id})
        return False
    
    db.delete(note)
    db.commit()
    
    logger.info("Note deleted successfully", extra={"note_id": note_id})
    return True