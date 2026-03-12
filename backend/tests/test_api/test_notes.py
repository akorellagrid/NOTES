"""
End-to-end tests for notes API endpoints.
"""
from __future__ import annotations

import pytest
from fastapi import status
from fastapi.testclient import TestClient


class TestNotesAPI:
    """Test class for notes API endpoints."""

    def test_create_note(self, test_client: TestClient, sample_note_data):
        """Test creating a note via POST /notes."""
        response = test_client.post("/notes/", json=sample_note_data)
        
        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["title"] == sample_note_data["title"]
        assert data["content"] == sample_note_data["content"]
        assert "id" in data
        assert "created_at" in data
        assert "updated_at" in data

    def test_get_note(self, test_client: TestClient, sample_note_data):
        """Test retrieving a note via GET /notes/{id}."""
        # First create a note
        create_response = test_client.post("/notes/", json=sample_note_data)
        created_note = create_response.json()
        note_id = created_note["id"]
        
        # Then retrieve it
        response = test_client.get(f"/notes/{note_id}")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == note_id
        assert data["title"] == sample_note_data["title"]
        assert data["content"] == sample_note_data["content"]

    def test_get_note_not_found(self, test_client: TestClient):
        """Test retrieving a non-existent note returns 404."""
        response = test_client.get("/notes/999")
        
        assert response.status_code == status.HTTP_404_NOT_FOUND
        assert response.json()["detail"] == "Note not found"

    def test_list_notes(self, test_client: TestClient, sample_note_data):
        """Test listing all notes via GET /notes."""
        # Create a few notes
        note1_data = {**sample_note_data, "title": "Note 1"}
        note2_data = {**sample_note_data, "title": "Note 2"}
        
        test_client.post("/notes/", json=note1_data)
        test_client.post("/notes/", json=note2_data)
        
        # List all notes
        response = test_client.get("/notes/")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data) == 2
        assert data[0]["title"] == "Note 1"
        assert data[1]["title"] == "Note 2"

    def test_list_notes_empty(self, test_client: TestClient):
        """Test listing notes when none exist."""
        response = test_client.get("/notes/")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data == []

    def test_update_note_put(self, test_client: TestClient, sample_note_data):
        """Test updating a note via PUT /notes/{id}."""
        # Create a note
        create_response = test_client.post("/notes/", json=sample_note_data)
        note_id = create_response.json()["id"]
        
        # Update it
        update_data = {"title": "Updated Title", "content": "Updated content"}
        response = test_client.put(f"/notes/{note_id}", json=update_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == note_id
        assert data["title"] == "Updated Title"
        assert data["content"] == "Updated content"

    def test_update_note_patch(self, test_client: TestClient, sample_note_data):
        """Test partially updating a note via PATCH /notes/{id}."""
        # Create a note
        create_response = test_client.post("/notes/", json=sample_note_data)
        note_id = create_response.json()["id"]
        original_content = create_response.json()["content"]
        
        # Update only title
        update_data = {"title": "Partially Updated Title"}
        response = test_client.patch(f"/notes/{note_id}", json=update_data)
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["id"] == note_id
        assert data["title"] == "Partially Updated Title"
        assert data["content"] == original_content  # Should remain unchanged

    def test_update_note_not_found(self, test_client: TestClient):
        """Test updating a non-existent note returns 404."""
        update_data = {"title": "Updated Title"}
        response = test_client.patch("/notes/999", json=update_data)
        
        assert response.status_code == status.HTTP_404_NOT_FOUND
        assert response.json()["detail"] == "Note not found"

    def test_delete_note(self, test_client: TestClient, sample_note_data):
        """Test deleting a note via DELETE /notes/{id}."""
        # Create a note
        create_response = test_client.post("/notes/", json=sample_note_data)
        note_id = create_response.json()["id"]
        
        # Delete it
        response = test_client.delete(f"/notes/{note_id}")
        
        assert response.status_code == status.HTTP_204_NO_CONTENT
        
        # Verify it's gone
        get_response = test_client.get(f"/notes/{note_id}")
        assert get_response.status_code == status.HTTP_404_NOT_FOUND

    def test_delete_note_not_found(self, test_client: TestClient):
        """Test deleting a non-existent note returns 404."""
        response = test_client.delete("/notes/999")
        
        assert response.status_code == status.HTTP_404_NOT_FOUND
        assert response.json()["detail"] == "Note not found"