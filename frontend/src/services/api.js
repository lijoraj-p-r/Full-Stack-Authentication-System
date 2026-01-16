import axios from 'axios';
import { storage } from '../utils/storage';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

// Store navigation function for use in interceptors
let navigateFunction = null;

export const setNavigateFunction = (navigate) => {
  navigateFunction = navigate;
};

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 second timeout
});

// Request interceptor to add token
api.interceptors.request.use(
  (config) => {
    const token = storage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Handle network errors
    if (!error.response) {
      console.error('Network error:', error.message);
      return Promise.reject(new Error('Network error. Please check your connection.'));
    }

    const status = error.response.status;
    
    // Handle 401 Unauthorized
    if (status === 401) {
      // Clear tokens
      storage.removeItem('accessToken');
      storage.removeItem('refreshToken');
      
      // Use navigate if available, otherwise fallback to window.location
      if (navigateFunction) {
        navigateFunction('/login');
      } else {
        // Fallback for cases where navigate isn't set yet
        window.location.href = '/login';
      }
    }
    
    // Handle 403 Forbidden
    if (status === 403) {
      console.error('Access forbidden');
    }
    
    // Handle 500 Server Error
    if (status >= 500) {
      console.error('Server error:', error.response.data);
    }
    
    return Promise.reject(error);
  }
);

export const authAPI = {
  register: (data) => api.post('/auth/register', data),
  verifyOtp: (data) => api.post('/auth/verify-otp', data),
  login: (data) => api.post('/auth/login', data),
  forgotPassword: (data) => api.post('/auth/forgot-password', data),
  resetPassword: (data) => api.post('/auth/reset-password', data),
};

export const userAPI = {
  getCurrentUser: () => api.get('/users/me'),
};

export default api;
