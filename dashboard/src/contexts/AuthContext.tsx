import React, { createContext, useState, useContext, useEffect } from 'react';
import { authService, User } from '../services/authService';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<{ user: any }>;
  googleLogin: (googleToken: string) => Promise<{ user: any }>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  type: string | null;
  isLoggingOut: boolean;
  hasRole: (role: string) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

/** Derive roles from the user's type field (mirrors backend logic). */
function getRoles(user: User | null): string[] {
  if (!user) return [];
  const base = ['ROLE_USER'];
  switch (user.type) {
    case 'admin':   return [...base, 'ROLE_ADMIN'];
    case 'seller':  return [...base, 'ROLE_SELLER'];
    case 'buyer':   return [...base, 'ROLE_BUYER'];
    case 'support': return [...base, 'ROLE_SUPPORT'];
    default:        return base;
  }
}

export const AuthProvider: React.FC<{children: React.ReactNode}> = ({ children }) => {
  const [user, setUser] = useState<User | null>(authService.getCurrentUser());
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const isAuthenticated = authService.isAuthenticated();
  const type = user?.type || null;

  const hasRole = (role: string) => getRoles(user).includes(role);

  const login = async (email: string, password: string) => {
    const data = await authService.login(email, password);
    setUser(data.user);
    return data;
  };

  const googleLogin = async (googleToken: string) => {
    const data = await authService.googleLogin(googleToken);
    setUser(data as any);
    return { user: data };
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
    <AuthContext.Provider value={{ user, login, googleLogin, logout, isAuthenticated, type, isLoggingOut, hasRole }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
};
