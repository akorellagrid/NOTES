/**
 * Utility functions and helpers
 */

/**
 * Date formatting utilities
 */
export const formatters = {
  /**
   * Format ISO date string to localized string
   * @param {string} isoString - ISO date string
   * @returns {string} Formatted date string
   */
  date(isoString) {
    try {
      return new Date(isoString).toLocaleString();
    } catch {
      return isoString;
    }
  },

  /**
   * Truncate text to specified length
   * @param {string} text - Text to truncate
   * @param {number} maxLength - Maximum length
   * @returns {string} Truncated text
   */
  truncate(text, maxLength = 100) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  },
};

/**
 * Validation utilities
 */
export const validators = {
  /**
   * Check if value is required (not empty)
   * @param {any} value - Value to validate
   * @returns {boolean} True if valid
   */
  required(value) {
    return value && value.toString().trim().length > 0;
  },

  /**
   * Check maximum length
   * @param {string} value - Value to validate
   * @param {number} max - Maximum length
   * @returns {boolean} True if valid
   */
  maxLength(value, max) {
    return value.length <= max;
  },

  /**
   * Check minimum length
   * @param {string} value - Value to validate
   * @param {number} min - Minimum length
   * @returns {boolean} True if valid
   */
  minLength(value, min) {
    return value.length >= min;
  },

  /**
   * Validate a note object
   * @param {Object} note - Note object to validate
   * @param {string} note.title - Note title
   * @param {string} note.content - Note content
   * @returns {Object} Validation result with isValid and errors
   */
  validateNote(note) {
    const errors = {};
    
    // Validate title
    if (!note.title || typeof note.title !== 'string') {
      errors.title = 'Title is required';
    } else {
      const title = note.title.trim();
      if (title.length === 0) {
        errors.title = 'Title cannot be empty';
      } else if (title.length > 200) {
        errors.title = 'Title must be 200 characters or less';
      }
    }
    
    // Validate content
    if (!note.content || typeof note.content !== 'string') {
      errors.content = 'Content is required';
    } else {
      const content = note.content.trim();
      if (content.length === 0) {
        errors.content = 'Content cannot be empty';
      } else if (content.length > 10000) {
        errors.content = 'Content must be 10,000 characters or less';
      }
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors,
    };
  },
};

/**
 * Debounce function execution
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in milliseconds
 * @returns {Function} Debounced function
 */
export const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

/**
 * Local storage utilities
 */
export const storage = {
  /**
   * Get item from localStorage
   * @param {string} key - Storage key
   * @param {any} defaultValue - Default value if not found
   * @returns {any} Stored value or default
   */
  get(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch {
      return defaultValue;
    }
  },

  /**
   * Set item in localStorage
   * @param {string} key - Storage key
   * @param {any} value - Value to store
   * @returns {boolean} Success status
   */
  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch {
      return false;
    }
  },

  /**
   * Remove item from localStorage
   * @param {string} key - Storage key
   * @returns {boolean} Success status
   */
  remove(key) {
    try {
      localStorage.removeItem(key);
      return true;
    } catch {
      return false;
    }
  },
};

/**
 * DOM utilities
 */
export const dom = {
  /**
   * Safely get element by ID
   * @param {string} id - Element ID
   * @returns {Element|null} Element or null
   */
  getElementById(id) {
    return document.getElementById(id);
  },

  /**
   * Create element with attributes
   * @param {string} tag - HTML tag name
   * @param {Object} attributes - Element attributes
   * @param {string} textContent - Text content
   * @returns {Element} Created element
   */
  createElement(tag, attributes = {}, textContent = '') {
    const element = document.createElement(tag);
    
    Object.entries(attributes).forEach(([key, value]) => {
      if (key === 'className') {
        element.className = value;
      } else {
        element.setAttribute(key, value);
      }
    });
    
    if (textContent) {
      element.textContent = textContent;
    }
    
    return element;
  },

  /**
   * Add event listener with cleanup
   * @param {Element} element - Target element
   * @param {string} event - Event type
   * @param {Function} handler - Event handler
   * @returns {Function} Cleanup function
   */
  addEventListener(element, event, handler) {
    element.addEventListener(event, handler);
    return () => element.removeEventListener(event, handler);
  },
};

/**
 * Error handling utilities
 */
export const errorHandler = {
  /**
   * Extract error message from various error types
   * @param {any} error - Error object
   * @returns {string} Error message
   */
  getErrorMessage(error) {
    if (typeof error === 'string') {
      return error;
    }
    
    if (error && error.message) {
      return error.message;
    }
    
    if (error && error.detail) {
      if (Array.isArray(error.detail)) {
        return error.detail.map(e => e.msg || e.message || e).join(', ');
      }
      return error.detail;
    }
    
    return 'An unexpected error occurred';
  },

  /**
   * Log error to console with context
   * @param {string} context - Error context
   * @param {any} error - Error object
   */
  logError(context, error) {
    console.error(`[${context}]`, error);
  },
};