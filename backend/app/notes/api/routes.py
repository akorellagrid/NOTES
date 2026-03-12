"""
API routes for notes.
"""
from __future__ import annotations

import logging
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from backend.app.notes.schema.schemas import Note, NoteCreate, NoteUpdate
from backend.app.notes.service import notes_service
from backend.app.notes.service.notes_service import NoteNotFoundError, NoteValidationError
from backend.database.dependencies import get_db

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/notes", tags=["notes"])


@router.post("", response_model=Note, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=Note, status_code=status.HTTP_201_CREATED)
async def create_note(
    payload: NoteCreate,
    db: Session = Depends(get_db)
) -> Note:
    """Create a new note."""
    logger.info("API: Creating note", extra={"title": payload.title[:50]})
    
    try:
        note = notes_service.create_note(db=db, note_data=payload)
        return Note.model_validate(note)
    except NoteValidationError as e:
        logger.warning("API: Note creation failed", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )
    except Exception as e:
        logger.error("API: Unexpected error creating note", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("/{note_id}", response_model=Note)
@router.get("/{note_id}/", response_model=Note)
async def get_note(
    note_id: int,
    db: Session = Depends(get_db)
) -> Note:
    """Retrieve a note by ID."""
    logger.debug("API: Getting note", extra={"note_id": note_id})
    
    try:
        note = notes_service.get_note(db=db, note_id=note_id)
        return Note.model_validate(note)
    except NoteNotFoundError:
        logger.warning("API: Note not found", extra={"note_id": note_id})
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Note not found"
        )
    except Exception as e:
        logger.error("API: Unexpected error getting note", extra={"note_id": note_id, "error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get("", response_model=List[Note])
@router.get("/", response_model=List[Note])
async def list_notes(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[Note]:
    """List all notes with pagination."""
    logger.debug("API: Listing notes", extra={"skip": skip, "limit": limit})
    
    try:
        notes = notes_service.list_notes(db=db, skip=skip, limit=limit)
        return [Note.model_validate(note) for note in notes]
    except Exception as e:
        logger.error("API: Unexpected error listing notes", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.put("/{note_id}", response_model=Note)
@router.put("/{note_id}/", response_model=Note)
async def replace_note(
    note_id: int,
    payload: NoteCreate,
    db: Session = Depends(get_db)
) -> Note:
    """Replace a note (full update)."""
    logger.info("API: Replacing note", extra={"note_id": note_id})
    
    try:
        # Convert NoteCreate to NoteUpdate for full replacement
        update_data = NoteUpdate(title=payload.title, content=payload.content)
        note = notes_service.update_note(db=db, note_id=note_id, note_data=update_data)
        return Note.model_validate(note)
    except NoteNotFoundError:
        logger.warning("API: Note not found for replacement", extra={"note_id": note_id})
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Note not found"
        )
    except NoteValidationError as e:
        logger.warning("API: Note replacement failed", extra={"note_id": note_id, "error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )
    except Exception as e:
        logger.error("API: Unexpected error replacing note", extra={"note_id": note_id, "error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.patch("/{note_id}", response_model=Note)
@router.patch("/{note_id}/", response_model=Note)
async def update_note(
    note_id: int,
    payload: NoteUpdate,
    db: Session = Depends(get_db)
) -> Note:
    """Update a note (partial update)."""
    logger.info("API: Updating note", extra={"note_id": note_id})
    
    try:
        note = notes_service.update_note(db=db, note_id=note_id, note_data=payload)
        return Note.model_validate(note)
    except NoteNotFoundError:
        logger.warning("API: Note not found for update", extra={"note_id": note_id})
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Note not found"
        )
    except NoteValidationError as e:
        logger.warning("API: Note update failed", extra={"note_id": note_id, "error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(e)
        )
    except Exception as e:
        logger.error("API: Unexpected error updating note", extra={"note_id": note_id, "error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.delete("/{note_id}", status_code=status.HTTP_204_NO_CONTENT)
@router.delete("/{note_id}/", status_code=status.HTTP_204_NO_CONTENT)
async def delete_note(
    note_id: int,
    db: Session = Depends(get_db)
) -> Response:
    """Delete a note."""
    logger.info("API: Deleting note", extra={"note_id": note_id})
    
    try:
        notes_service.delete_note(db=db, note_id=note_id)
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    except NoteNotFoundError:
        logger.warning("API: Note not found for deletion", extra={"note_id": note_id})
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Note not found"
        )
    except Exception as e:
        logger.error("API: Unexpected error deleting note", extra={"note_id": note_id, "error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )