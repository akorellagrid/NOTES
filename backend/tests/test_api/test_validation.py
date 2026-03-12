"""
Tests for API validation errors.
"""
from __future__ import annotations

import pytest
from fastapi import status
from fastapi.testclient import TestClient


class TestValidationErrors:
    """Test class for validation error scenarios."""

    def test_create_note_empty_title(self, test_client: TestClient):
        """Test creating a note with empty title returns 422."""
        invalid_data = {"title": "", "content": "Valid content"}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
        error_detail = response.json()["detail"]
        assert any("title" in str(error).lower() for error in error_detail)

    def test_create_note_whitespace_only_title(self, test_client: TestClient):
        """Test creating a note with whitespace-only title returns 422."""
        invalid_data = {"title": "   ", "content": "Valid content"}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_create_note_title_too_long(self, test_client: TestClient):
        """Test creating a note with title longer than 200 characters returns 422."""
        long_title = "x" * 201  # 201 characters
        invalid_data = {"title": long_title, "content": "Valid content"}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_create_note_empty_content(self, test_client: TestClient):
        """Test creating a note with empty content returns 422."""
        invalid_data = {"title": "Valid title", "content": ""}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
        error_detail = response.json()["detail"]
        assert any("content" in str(error).lower() for error in error_detail)

    def test_create_note_whitespace_only_content(self, test_client: TestClient):
        """Test creating a note with whitespace-only content returns 422."""
        invalid_data = {"title": "Valid title", "content": "   "}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_create_note_content_too_long(self, test_client: TestClient):
        """Test creating a note with content longer than 10,000 characters returns 422."""
        long_content = "x" * 10001  # 10,001 characters
        invalid_data = {"title": "Valid title", "content": long_content}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_create_note_missing_title(self, test_client: TestClient):
        """Test creating a note without title returns 422."""
        invalid_data = {"content": "Valid content"}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_create_note_missing_content(self, test_client: TestClient):
        """Test creating a note without content returns 422."""
        invalid_data = {"title": "Valid title"}
        response = test_client.post("/notes/", json=invalid_data)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_update_note_empty_fields(self, test_client: TestClient, sample_note_data):
        """Test updating a note with empty fields returns 422."""
        # Create a note first
        create_response = test_client.post("/notes/", json=sample_note_data)
        note_id = create_response.json()["id"]
        
        # Try to update with empty fields
        invalid_update = {"title": "", "content": ""}
        response = test_client.patch(f"/notes/{note_id}", json=invalid_update)
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_update_note_no_fields(self, test_client: TestClient, sample_note_data):
        """Test updating a note with no fields returns 422."""
        # Create a note first
        create_response = test_client.post("/notes/", json=sample_note_data)
        note_id = create_response.json()["id"]
        
        # Try to update with no fields
        response = test_client.patch(f"/notes/{note_id}", json={})
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

    def test_whitespace_stripping(self, test_client: TestClient):
        """Test that whitespace is properly stripped from fields."""
        data_with_whitespace = {
            "title": "  Title with spaces  ",
            "content": "  Content with spaces  "
        }
        response = test_client.post("/notes/", json=data_with_whitespace)
        
        assert response.status_code == status.HTTP_201_CREATED
        created_note = response.json()
        assert created_note["title"] == "Title with spaces"
        assert created_note["content"] == "Content with spaces"