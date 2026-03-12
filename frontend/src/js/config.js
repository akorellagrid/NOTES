/**
 * Application configuration based on environment
 */

/**
 * Get current environment
 * @returns {string} Current environment (development/production)
 */
function getEnvironment() {
  // In a real build system, this would be replaced by webpack DefinePlugin
  return window.location.hostname === 'localhost' ? 'development' : 'production';
}

/**
 * Application configuration
 */
export const config = {
  development: {
    apiBaseUrl: '/api',
    environment: 'development',
    debug: true,
    version: '1.0.0',
  },
  production: {
    apiBaseUrl: '/api',
    environment: 'production',
    debug: false,
    version: '1.0.0',
  },
};

/**
 * Get current configuration based on environment
 * @returns {Object} Current configuration object
 */
export function getConfig() {
  const env = getEnvironment();
  return config[env] || config.development;
}

/**
 * API endpoints configuration
 */
export const endpoints = {
  notes: {
    list: '/notes',           // Remove trailing slash to match backend
    create: '/notes',         // Remove trailing slash to match backend
    get: (id) => `/notes/${id}`,      // Individual routes DON'T need trailing slash
    update: (id) => `/notes/${id}`,   // Individual routes DON'T need trailing slash
    delete: (id) => `/notes/${id}`,   // Individual routes DON'T need trailing slash
  },
  health: '/health',
};

/**
 * Application constants
 */
export const constants = {
  MAX_TITLE_LENGTH: 200,
  MAX_CONTENT_LENGTH: 10000,
  DEBOUNCE_DELAY: 300,
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000,
};