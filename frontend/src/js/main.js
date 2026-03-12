/**
 * Main application entry point
 */

// Import CSS
import '../css/main.css';

import { apiClient } from './api.js';
import { uiManager } from './ui.js';
import { validators, debounce, errorHandler } from './utils.js';

/**
 * Main application class
 */
class NotesApp {
  constructor() {
    this.api = apiClient;
    this.ui = uiManager;
    this.isInitialized = false;
  }

  /**
   * Initialize the application
   */
  async init() {
    if (this.isInitialized) return;
    
    try {
      console.log('Initializing Notes App...');
      
      // Set up event listeners
      this.setupEventListeners();
      
      // Override UI callbacks
      this.ui.onUpdateNote = this.handleUpdateNote.bind(this);
      this.ui.onDeleteNote = this.handleDeleteNote.bind(this);
      
      // Load initial data
      await this.refreshNotes();
      
      this.isInitialized = true;
      console.log('Notes App initialized successfully');
      
    } catch (error) {
      console.error('Failed to initialize app:', error);
      this.ui.setStatus('Failed to initialize application', true);
    }
  }

  /**
   * Set up event listeners
   */
  setupEventListeners() {
    // Create form submission
    if (this.ui.elements.formEl) {
      this.ui.elements.formEl.addEventListener('submit', this.handleCreateNote.bind(this));
    }
    
    // Refresh button
    if (this.ui.elements.refreshBtn) {
      this.ui.elements.refreshBtn.addEventListener('click', this.handleRefresh.bind(this));
    }
    
    // Add debounced input validation
    if (this.ui.elements.titleEl) {
      const debouncedValidation = debounce(this.validateForm.bind(this), 300);
      this.ui.elements.titleEl.addEventListener('input', debouncedValidation);
    }
    
    if (this.ui.elements.contentEl) {
      const debouncedValidation = debounce(this.validateForm.bind(this), 300);
      this.ui.elements.contentEl.addEventListener('input', debouncedValidation);
    }
  }

  /**
   * Handle create note form submission
   * @param {Event} event - Form submit event
   */
  async handleCreateNote(event) {
    event.preventDefault();
    
    const title = this.ui.elements.titleEl?.value.trim();
    const content = this.ui.elements.contentEl?.value.trim();
    
    if (!title || !content) {
      this.ui.setStatus('Title and content are required.', true);
      return;
    }

    // Validate note data
    const validation = validators.validateNote({ title, content });
    if (!validation.isValid) {
      const errorMessages = Object.values(validation.errors).join(', ');
      this.ui.setStatus(errorMessages, true);
      return;
    }

    try {
      this.ui.setLoading(true);
      this.ui.setStatus('Creating...');
      
      await this.api.createNote({ title, content });
      
      this.ui.setStatus('Created.');
      this.ui.resetForm();
      await this.refreshNotes();
      
    } catch (error) {
      const message = errorHandler.getErrorMessage(error);
      this.ui.setStatus(message || 'Create failed', true);
      errorHandler.logError('Create Note', error);
    } finally {
      this.ui.setLoading(false);
    }
  }

  /**
   * Handle refresh button click
   * @param {Event} event - Click event
   */
  async handleRefresh(event) {
    event.preventDefault();
    await this.refreshNotes();
  }

  /**
   * Handle note update
   * @param {number} noteId - Note ID
   * @param {Object} data - Update data
   */
  async handleUpdateNote(noteId, data) {
    // Validate update data
    const validation = validators.validateNote(data);
    if (!validation.isValid) {
      const errorMessages = Object.values(validation.errors).join(', ');
      this.ui.setStatus(errorMessages, true);
      return;
    }

    try {
      this.ui.setLoading(true);
      this.ui.setStatus('Saving...');
      
      const updatedNote = await this.api.updateNote(noteId, data);
      
      this.ui.setStatus('Saved.');
      await this.refreshNotes();
      
    } catch (error) {
      const message = errorHandler.getErrorMessage(error);
      this.ui.setStatus(message || 'Save failed', true);
      errorHandler.logError('Update Note', error);
    } finally {
      this.ui.setLoading(false);
    }
  }

  /**
   * Handle note deletion
   * @param {number} noteId - Note ID
   */
  async handleDeleteNote(noteId) {
    try {
      this.ui.setLoading(true);
      this.ui.setStatus('Deleting...');
      
      await this.api.deleteNote(noteId);
      
      this.ui.setStatus('Deleted.');
      if (this.ui.state.expandedNoteId === noteId) {
        this.ui.state.expandedNoteId = null;
      }
      await this.refreshNotes();
      
    } catch (error) {
      const message = errorHandler.getErrorMessage(error);
      this.ui.setStatus(message || 'Delete failed', true);
      errorHandler.logError('Delete Note', error);
    } finally {
      this.ui.setLoading(false);
    }
  }

  /**
   * Refresh notes list
   */
  async refreshNotes() {
    try {
      this.ui.setLoading(true);
      this.ui.setStatus('Loading...');
      
      const notes = await this.api.listNotes();
      this.ui.renderNotes(notes);
      
      this.ui.setStatus(`Loaded ${notes.length} note(s).`);
      
    } catch (error) {
      const message = errorHandler.getErrorMessage(error);
      this.ui.setStatus(message || 'Failed to load notes', true);
      errorHandler.logError('Refresh Notes', error);
    } finally {
      this.ui.setLoading(false);
    }
  }

  /**
   * Validate form inputs
   */
  validateForm() {
    const title = this.ui.elements.titleEl?.value.trim();
    const content = this.ui.elements.contentEl?.value.trim();
    
    if (!title && !content) return;
    
    const validation = validators.validateNote({ title: title || 'x', content: content || 'x' });
    
    if (!validation.isValid) {
      const errorMessages = Object.values(validation.errors).join(', ');
      this.ui.setStatus(errorMessages, true);
    } else {
      this.ui.setStatus('');
    }
  }

  /**
   * Clean up the application
   */
  cleanup() {
    this.ui.cleanup();
    this.isInitialized = false;
  }
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', async () => {
  const app = new NotesApp();
  await app.init();
  
  // Make app available globally for debugging
  window.notesApp = app;
});

// Handle page unload
window.addEventListener('beforeunload', () => {
  if (window.notesApp) {
    window.notesApp.cleanup();
  }
});