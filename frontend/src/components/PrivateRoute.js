import React from 'react';
import { Navigate } from 'react-router-dom';
import { storage } from '../utils/storage';

const PrivateRoute = ({ children }) => {
  const token = storage.getItem('accessToken');
  return token ? children : <Navigate to="/login" replace />;
};

export default PrivateRoute;
