import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

interface ProtectedRouteProps {
  children: JSX.Element;
  allowedRoles: string[];
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children, allowedRoles }) => {
  const { isAuthenticated } = useAuth();

  const userStorage = localStorage.getItem('user');
  const userType = userStorage ? JSON.parse(userStorage).type : '';
  
  if (!isAuthenticated) return <Navigate to="/" />;
  if (!allowedRoles.includes(userType || '')) return <Navigate to="/unauthorized" />;

  return children;
};

export default ProtectedRoute;
