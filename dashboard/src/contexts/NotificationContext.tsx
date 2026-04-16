// src/contexts/NotificationContext.tsx
// Global context — provides notification state to every component in the app.
// Follows the same pattern as AuthContext.tsx.

import React, { createContext, useContext } from 'react';
import { useNotifications, OrderNotification, OrderNotificationStatus } from '../hooks/useNotifications';

// Re-export types so consumers don't need to import from two places
export type { OrderNotification, OrderNotificationStatus };

// ── Context shape ─────────────────────────────────────────────────────────────

interface NotificationContextType {
  notifications:  OrderNotification[];
  unreadCount:    number;
  isConnected:    boolean;
  toast:          OrderNotification | null;
  markAllAsRead:  () => void;
  markAsRead:     (id: string) => void;
  dismissToast:   () => void;
  /** Convenience: the most recently received notification (first in array) */
  latestNotification: OrderNotification | null;
}

// ── Context ───────────────────────────────────────────────────────────────────

const NotificationContext = createContext<NotificationContextType | undefined>(undefined);

// ── Provider ──────────────────────────────────────────────────────────────────

export const NotificationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const {
    notifications,
    unreadCount,
    isConnected,
    toast,
    markAllAsRead,
    markAsRead,
    dismissToast,
  } = useNotifications();

  const latestNotification = notifications.length > 0 ? notifications[0] : null;

  return (
    <NotificationContext.Provider
      value={{
        notifications,
        unreadCount,
        isConnected,
        toast,
        markAllAsRead,
        markAsRead,
        dismissToast,
        latestNotification,
      }}
    >
      {children}
    </NotificationContext.Provider>
  );
};

// ── Hook ──────────────────────────────────────────────────────────────────────

export const useNotificationContext = (): NotificationContextType => {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotificationContext must be used within NotificationProvider');
  }
  return context;
};
