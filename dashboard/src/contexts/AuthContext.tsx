import React, { createContext, useState, useContext, useEffect } from 'react';
import { authService, User } from '../services/authService';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<{ user: any; redirectTo: string | null }>;
  googleLogin: (googleToken: string) => Promise<{ user: any; redirectTo: string | null }>;
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

/**
 * Returns the route the seller should land on after login.
 * Checks the user object (from API) AND the per-user localStorage flag set by demo mode.
 * Returns '/vendor/contract' when contract is unsigned, '/dishes' when signed.
 * Returns null for non-sellers.
 */
function getSellerRedirect(userData: any): string | null {
  const isSeller =
    userData?.type === 'seller' ||
    (userData as any)?.roles?.includes('ROLE_SELLER');

  if (!isSeller) return null;

  const userId = userData?.id ?? '';
  const signedViaAPI    = userData?.hasSignedVendorContract === true;
  // Per-user localStorage key prevents cross-session contamination
  const signedLocally   = localStorage.getItem(`vendorContractSigned_${userId}`) === 'true'
    // Fallback: legacy global key (for backward-compat with existing demo-mode sessions)
    || localStorage.getItem('vendorContractSigned') === 'true';

  return signedViaAPI || signedLocally ? '/dishes' : '/vendor/contract';
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
    const redirectTo = getSellerRedirect(data.user);
    return { ...data, redirectTo };
  };

  const googleLogin = async (googleToken: string) => {
    const data = await authService.googleLogin(googleToken);
    setUser(data as any);
    const userData = (data as any)?.user ?? data;
    const redirectTo = getSellerRedirect(userData);
    return { user: data, redirectTo };
  };

  const logout = async () => {
    try {
      setIsLoggingOut(true);
      // Clear per-user demo-mode contract flag before losing the user id
      const userId = user?.id ?? (authService.getCurrentUser() as any)?.id;
      if (userId) {
        localStorage.removeItem(`vendorContractSigned_${userId}`);
      }
      localStorage.removeItem('vendorContractSigned'); // also clear legacy key
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
