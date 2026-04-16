import React, { createContext, useState, useContext, useEffect } from 'react';
import { authService, User } from '../services/authService';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  googleLogin: (googleToken: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  type: string | null;
  isLoggingOut: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{children: React.ReactNode}> = ({ children }) => {
  
  const [user, setUser] = useState<User | null>(authService.getCurrentUser());
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const isAuthenticated = authService.isAuthenticated();
  const type = user?.type || null;
  
  const login = async (email: string, password: string) => {
    const data = await authService.login(email, password);
    setUser(data.user);
  };

  const googleLogin = async (googleToken: string) => {
    const user = await authService.googleLogin(googleToken);
    setUser(user);
  };

  const logout = async () => {
    try {
      setIsLoggingOut(true);
      await authService.logout();
      setUser(null);
    } catch (error) {
      console.error("Logout failed:", error);
    } finally {
      setIsLoggingOut(false);
    }
  };

  useEffect(() => {
    const storedUser = authService.getCurrentUser();
    if (storedUser) setUser(storedUser);
  }, []);

  return (
    <AuthContext.Provider value={{ user, login, googleLogin, logout, isAuthenticated, type, isLoggingOut }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
};
