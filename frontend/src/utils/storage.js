/**
 * Secure localStorage utility with error handling
 * Handles cases where localStorage might be disabled or unavailable
 */

const isStorageAvailable = () => {
  try {
    const test = '__storage_test__';
    localStorage.setItem(test, test);
    localStorage.removeItem(test);
    return true;
  } catch (e) {
    return false;
  }
};

export const storage = {
  setItem: (key, value) => {
    if (!isStorageAvailable()) {
      console.warn('localStorage is not available');
      return false;
    }
    try {
      localStorage.setItem(key, value);
      return true;
    } catch (error) {
      console.error('Error setting localStorage item:', error);
      return false;
    }
  },

  getItem: (key) => {
    if (!isStorageAvailable()) {
      return null;
    }
    try {
      return localStorage.getItem(key);
    } catch (error) {
      console.error('Error getting localStorage item:', error);
      return null;
    }
  },

  removeItem: (key) => {
    if (!isStorageAvailable()) {
      return false;
    }
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error('Error removing localStorage item:', error);
      return false;
    }
  },

  clear: () => {
    if (!isStorageAvailable()) {
      return false;
    }
    try {
      localStorage.clear();
      return true;
    } catch (error) {
      console.error('Error clearing localStorage:', error);
      return false;
    }
  },
};
