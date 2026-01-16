/**
 * Security utilities for XSS protection and input sanitization
 */

/**
 * Escapes HTML to prevent XSS attacks
 * @param {string} text - Text to escape
 * @returns {string} - Escaped text
 */
export const escapeHtml = (text) => {
  if (typeof text !== 'string') {
    return text;
  }
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  };
  return text.replace(/[&<>"']/g, (m) => map[m]);
};

/**
 * Sanitizes user input by escaping HTML
 * @param {string} input - User input to sanitize
 * @returns {string} - Sanitized input
 */
export const sanitizeInput = (input) => {
  if (typeof input !== 'string') {
    return input;
  }
  return escapeHtml(input.trim());
};

/**
 * Validates that a string doesn't contain script tags
 * @param {string} input - Input to validate
 * @returns {boolean} - True if safe
 */
export const isSafeString = (input) => {
  if (typeof input !== 'string') {
    return false;
  }
  const scriptPattern = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
  return !scriptPattern.test(input);
};
