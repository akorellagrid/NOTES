/**
 * API client for HTTP communication
 */

import { getConfig, endpoints } from './config.js';
import { errorHandler } from './utils.js';

/**
 * HTTP client for API communication
 */
export class ApiClient {
  constructor() {
    this.config = getConfig();
    this.baseURL = this.config.apiBaseUrl;
    this.timeout = 10000; // 10 seconds
    this.retries = 3;
    this.retryDelay = 1000; // 1 second
  }

  /**
   * Make HTTP request with retry logic
   * @param {string} method - HTTP method
   * @param {string} path - API path
   * @param {Object} data - Request data
   * @param {Object} options - Request options
   * @returns {Promise<any>} Response data
   */
  async request(method, path, data = null, options = {}) {
    const url = `${this.baseURL}${path}`;
    const requestOptions = {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      signal: AbortSignal.timeout(this.timeout),
    };

    if (data && ['POST', 'PUT', 'PATCH'].includes(method)) {
      requestOptions.body = JSON.stringify(data);
    }

    let lastError;
    for (let attempt = 0; attempt <= this.retries; attempt++) {
      try {
        const response = await fetch(url, requestOptions);
        
        if (!response.ok) {
          const errorText = await response.text();
          let errorData;
          try {
            errorData = JSON.parse(errorText);
          } catch {
            errorData = { detail: errorText || `HTTP ${response.status}` };
          }
          
          const error = new ApiError(
            errorHandler.getErrorMessage(errorData),
            response.status,
            errorData
          );
          throw error;
        }

        if (response.status === 204) {
          return null;
        }

        return await response.json();
      } catch (error) {
        lastError = error;
        
        if (attempt < this.retries && this.shouldRetry(error)) {
          await this.delay(this.retryDelay * Math.pow(2, attempt));
          continue;
        }
        
        break;
      }
    }

    errorHandler.logError('API Request', lastError);
    throw lastError;
  }

  /**
   * Determine if request should be retried
   * @param {Error} error - Request error
   * @returns {boolean} Whether to retry
   */
  shouldRetry(error) {
    if (error.name === 'AbortError') return false;
    if (error instanceof ApiError && error.status < 500) return false;
    return true;
  }

  /**
   * Delay execution for specified milliseconds
   * @param {number} ms - Milliseconds to delay
   * @returns {Promise<void>}
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // HTTP method helpers
  get(path, options = {}) {
    return this.request('GET', path, null, options);
  }

  post(path, data, options = {}) {
    return this.request('POST', path, data, options);
  }

  put(path, data, options = {}) {
    return this.request('PUT', path, data, options);
  }

  patch(path, data, options = {}) {
    return this.request('PATCH', path, data, options);
  }

  delete(path, options = {}) {
    return this.request('DELETE', path, null, options);
  }

  // Notes API methods
  async createNote(data) {
    return this.post(endpoints.notes.create, data);
  }

  async getNote(id) {
    return this.get(endpoints.notes.get(id));
  }

  async updateNote(id, data) {
    return this.patch(endpoints.notes.update(id), data);
  }

  async replaceNote(id, data) {
    return this.put(endpoints.notes.update(id), data);
  }

  async deleteNote(id) {
    return this.delete(endpoints.notes.delete(id));
  }

  async listNotes() {
    return this.get(endpoints.notes.list);
  }

  async healthCheck() {
    return this.get(endpoints.health);
  }
}

/**
 * Custom API error class
 */
export class ApiError extends Error {
  constructor(message, status, data = null) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.data = data;
  }
}

// Default API client instance
export const apiClient = new ApiClient();