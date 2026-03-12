/**
 * UI management and DOM manipulation
 */

import { formatters, dom, errorHandler } from './utils.js';

/**
 * UI Manager class for DOM manipulation and user interface logic
 */
export class UIManager {
  constructor() {
    this.elements = this.initializeElements();
    this.state = {
      expandedNoteId: null,
      loading: false,
      error: null,
    };
    this.eventListeners = [];
  }

  /**
   * Initialize DOM element references
   * @returns {Object} Element references
   */
  initializeElements() {
    return {
      statusEl: dom.getElementById('status'),
      listEl: dom.getElementById('notesList'),
      formEl: dom.getElementById('createForm'),
      titleEl: dom.getElementById('title'),
      contentEl: dom.getElementById('content'),
      refreshBtn: dom.getElementById('refreshBtn'),
    };
  }

  /**
   * Set status message
   * @param {string} message - Status message
   * @param {boolean} isError - Whether this is an error message
   */
  setStatus(message, isError = false) {
    if (this.elements.statusEl) {
      this.elements.statusEl.textContent = message;
      this.elements.statusEl.classList.toggle('danger', isError);
    }
  }

  /**
   * Reset the create form
   */
  resetForm() {
    if (this.elements.titleEl) this.elements.titleEl.value = '';
    if (this.elements.contentEl) this.elements.contentEl.value = '';
  }

  /**
   * Set loading state
   * @param {boolean} loading - Loading state
   */
  setLoading(loading) {
    this.state.loading = loading;
    
    // Disable/enable form elements during loading
    const formElements = [
      this.elements.titleEl,
      this.elements.contentEl,
      this.elements.refreshBtn,
    ].filter(Boolean);
    
    formElements.forEach(element => {
      element.disabled = loading;
    });
    
    // Update status if loading
    if (loading) {
      this.setStatus('Loading...');
    }
  }

  /**
   * Render notes list
   * @param {Array} notes - Array of note objects
   */
  renderNotes(notes) {
    if (!this.elements.listEl) return;
    
    this.elements.listEl.innerHTML = '';
    
    if (!notes.length) {
      this.renderEmptyState();
      return;
    }

    notes.forEach(note => {
      const noteElement = this.createNoteElement(note);
      this.elements.listEl.appendChild(noteElement);
    });
  }

  /**
   * Render empty state when no notes exist
   */
  renderEmptyState() {
    const li = dom.createElement('li', { className: 'noteItem' });
    li.style.cursor = 'default';
    
    const noteDiv = dom.createElement('div', { className: 'note' });
    noteDiv.style.padding = '12px';
    
    const titleDiv = dom.createElement('div', { className: 'noteTitle' }, 'No notes yet');
    const metaDiv = dom.createElement('div', { className: 'noteMeta' }, 'Create one above.');
    
    noteDiv.appendChild(titleDiv);
    noteDiv.appendChild(metaDiv);
    li.appendChild(noteDiv);
    
    this.elements.listEl.appendChild(li);
  }

  /**
   * Create a note element
   * @param {Object} note - Note object
   * @returns {Element} Note element
   */
  createNoteElement(note) {
    const li = dom.createElement('li', { className: 'noteItem' });
    
    const details = dom.createElement('details', { className: 'note' });
    details.open = this.state.expandedNoteId === note.id;
    
    // Create note summary
    const summary = this.createNoteSummary(note);
    const divider = dom.createElement('div', { className: 'noteDivider' });
    const body = dom.createElement('div', { className: 'noteBody' });
    
    details.appendChild(summary);
    details.appendChild(divider);
    details.appendChild(body);
    
    // Handle expand/collapse
    const toggleCleanup = dom.addEventListener(details, 'toggle', () => {
      this.handleNoteToggle(details, note);
    });
    this.eventListeners.push(toggleCleanup);
    
    if (details.open) {
      this.renderViewMode(details, note);
    }
    
    li.appendChild(details);
    return li;
  }

  /**
   * Create note summary element
   * @param {Object} note - Note object
   * @returns {Element} Summary element
   */
  createNoteSummary(note) {
    const summary = dom.createElement('summary', { className: 'noteSummary' });
    
    const titleDiv = dom.createElement('div', { className: 'noteTitle' });
    titleDiv.textContent = note.title;
    
    const metaDiv = dom.createElement('div', { className: 'noteMeta' });
    metaDiv.textContent = `Updated ${formatters.date(note.updated_at)}`;
    
    summary.appendChild(titleDiv);
    summary.appendChild(metaDiv);
    
    return summary;
  }

  /**
   * Handle note toggle (expand/collapse)
   * @param {Element} details - Details element
   * @param {Object} note - Note object
   */
  handleNoteToggle(details, note) {
    if (details.open) {
      this.state.expandedNoteId = note.id;
      this.renderViewMode(details, note);
    } else if (this.state.expandedNoteId === note.id) {
      this.state.expandedNoteId = null;
    }
  }

  /**
   * Render note in view mode
   * @param {Element} detailsEl - Details element
   * @param {Object} note - Note object
   */
  renderViewMode(detailsEl, note) {
    const body = detailsEl.querySelector('.noteBody');
    if (!body) return;
    
    body.innerHTML = '';
    
    const contentDiv = dom.createElement('div', { className: 'noteContent' });
    contentDiv.textContent = note.content;
    
    const actionsDiv = dom.createElement('div', { className: 'noteActions' });
    
    const modifyBtn = dom.createElement('button', { 
      className: 'noteBtn',
      'data-action': 'modify',
      type: 'button'
    }, 'Modify');
    
    const deleteBtn = dom.createElement('button', { 
      className: 'noteBtn danger',
      'data-action': 'delete',
      type: 'button'
    }, 'Delete');
    
    actionsDiv.appendChild(modifyBtn);
    actionsDiv.appendChild(deleteBtn);
    
    body.appendChild(contentDiv);
    body.appendChild(actionsDiv);
    
    // Add event listeners
    const modifyCleanup = dom.addEventListener(modifyBtn, 'click', () => {
      this.renderEditMode(detailsEl, note);
      this.setStatus(`Modifying note`);
    });
    
    const deleteCleanup = dom.addEventListener(deleteBtn, 'click', async () => {
      if (confirm(`Delete this note?`)) {
        this.onDeleteNote(note.id);
      }
    });
    
    this.eventListeners.push(modifyCleanup, deleteCleanup);
  }

  /**
   * Render note in edit mode
   * @param {Element} detailsEl - Details element
   * @param {Object} note - Note object
   */
  renderEditMode(detailsEl, note) {
    const body = detailsEl.querySelector('.noteBody');
    if (!body) return;
    
    body.innerHTML = '';
    
    const formDiv = dom.createElement('div', { className: 'form' });
    formDiv.style.gap = '10px';
    
    // Title input
    const titleLabel = dom.createElement('label', { className: 'label' });
    const titleSpan = dom.createElement('span', {}, 'Title');
    const titleInput = dom.createElement('input', { 
      className: 'input',
      maxlength: '200',
      required: true,
      value: note.title
    });
    titleLabel.appendChild(titleSpan);
    titleLabel.appendChild(titleInput);
    
    // Content textarea
    const contentLabel = dom.createElement('label', { className: 'label' });
    const contentSpan = dom.createElement('span', {}, 'Content');
    const contentTextarea = dom.createElement('textarea', { 
      className: 'textarea',
      maxlength: '10000',
      required: true
    });
    contentTextarea.value = note.content;
    contentLabel.appendChild(contentSpan);
    contentLabel.appendChild(contentTextarea);
    
    // Action buttons
    const actionsDiv = dom.createElement('div', { className: 'row' });
    
    const saveBtn = dom.createElement('button', { 
      className: 'noteBtn',
      'data-action': 'save',
      type: 'button'
    }, 'Save');
    
    const cancelBtn = dom.createElement('button', { 
      className: 'noteBtn',
      'data-action': 'cancel',
      type: 'button'
    }, 'Cancel');
    
    const deleteBtn = dom.createElement('button', { 
      className: 'noteBtn danger',
      'data-action': 'delete',
      type: 'button'
    }, 'Delete');
    
    actionsDiv.appendChild(saveBtn);
    actionsDiv.appendChild(cancelBtn);
    actionsDiv.appendChild(deleteBtn);
    
    formDiv.appendChild(titleLabel);
    formDiv.appendChild(contentLabel);
    formDiv.appendChild(actionsDiv);
    body.appendChild(formDiv);
    
    // Add event listeners
    const cancelCleanup = dom.addEventListener(cancelBtn, 'click', () => {
      this.renderViewMode(detailsEl, note);
      this.setStatus('Cancelled.');
    });
    
    const deleteCleanup = dom.addEventListener(deleteBtn, 'click', async () => {
      if (confirm(`Delete this note?`)) {
        this.onDeleteNote(note.id);
      }
    });
    
    const saveCleanup = dom.addEventListener(saveBtn, 'click', () => {
      const title = titleInput.value.trim();
      const content = contentTextarea.value.trim();
      
      if (!title || !content) {
        this.setStatus('Title and content are required.', true);
        return;
      }
      
      this.onUpdateNote(note.id, { title, content });
    });
    
    this.eventListeners.push(cancelCleanup, deleteCleanup, saveCleanup);
  }

  /**
   * Handle note update (to be overridden by main app)
   * @param {number} noteId - Note ID
   * @param {Object} data - Update data
   */
  onUpdateNote(noteId, data) {
    console.log('Update note:', noteId, data);
  }

  /**
   * Handle note deletion (to be overridden by main app)
   * @param {number} noteId - Note ID
   */
  onDeleteNote(noteId) {
    console.log('Delete note:', noteId);
  }

  /**
   * Clean up event listeners
   */
  cleanup() {
    this.eventListeners.forEach(cleanup => cleanup());
    this.eventListeners = [];
  }
}

// Default UI manager instance
export const uiManager = new UIManager();