// src/hooks/useNotifications.ts
// Manages real-time order notifications via Mercure SSE.
// - Admin  → subscribes to /orders/all
// - Seller → subscribes to /orders/user/{userId}

import { useState, useEffect, useCallback, useRef } from 'react';
import { mercureService, MercureMessageCallback } from '../services/mercureService';
import { useAuth } from '../contexts/AuthContext';
import API from '../services/api';

// ── Types ─────────────────────────────────────────────────────────────────────

export type OrderNotificationStatus =
  | 'ORDER_CREATED'
  | 'ORDER_CONFIRMED'
  | 'ORDER_PREPARING'
  | 'ORDER_READY'
  | 'ORDER_PICKED_UP'
  | 'ORDER_DELIVERED'
  | 'ORDER_CANCELLED'
  | 'ORDER_UPDATED'
  | 'REFUND_COMPLETED'
  | 'REFUND_FAILED';

export interface OrderNotification {
  id: string;
  orderId: string;
  orderNumber: string;
  status: string;
  eventType: OrderNotificationStatus;
  storeName: string;
  totalAmount: number;
  updatedAt: string;
  isRead: boolean;
  receivedAt: string;
}

// ── Constants ─────────────────────────────────────────────────────────────────

const MAX_NOTIFICATIONS = 50;
const STORAGE_KEY       = 'cuisinous_notifications';
const MERCURE_PUBLIC_URL =
  (import.meta as Record<string, any>).env?.VITE_MERCURE_PUBLIC_URL ||
  'http://localhost:3001/.well-known/mercure';

// ── Helpers ───────────────────────────────────────────────────────────────────

function loadFromStorage(): OrderNotification[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as OrderNotification[]) : [];
  } catch {
    return [];
  }
}

function saveToStorage(notifications: OrderNotification[]): void {
  try {
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify(notifications.slice(0, MAX_NOTIFICATIONS))
    );
  } catch {
    // localStorage quota exceeded — fail silently
  }
}

function playBeep(): void {
  try {
    const AudioCtx =
      window.AudioContext ||
      (window as Record<string, any>).webkitAudioContext;
    if (!AudioCtx) return;
    const ctx        = new AudioCtx() as AudioContext;
    const osc        = ctx.createOscillator();
    const gain       = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = 'sine';
    osc.frequency.setValueAtTime(880, ctx.currentTime);
    gain.gain.setValueAtTime(0.25, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.35);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + 0.35);
  } catch {
    // Audio API not available
  }
}

// ── Hook ──────────────────────────────────────────────────────────────────────

export function useNotifications() {
  const { user, isAuthenticated } = useAuth();

  const [notifications, setNotifications] = useState<OrderNotification[]>(loadFromStorage);
  const [isConnected,   setIsConnected]   = useState(false);
  const [toast,         setToast]         = useState<OrderNotification | null>(null);

  const toastTimerRef       = useRef<ReturnType<typeof setTimeout> | null>(null);
  const statusPollRef       = useRef<ReturnType<typeof setInterval> | null>(null);

  const unreadCount = notifications.filter(n => !n.isRead).length;

  // Topic depends on role
  const topic =
    user?.type === 'admin'
      ? '/orders/all'
      : `/orders/user/${user?.id ?? 'unknown'}`;

  // ── Add incoming notification ──────────────────────────────────────────────
  const addNotification = useCallback(
    (raw: Record<string, unknown>) => {
      const notification: OrderNotification = {
        id:          crypto.randomUUID(),
        orderId:     String(raw.id ?? ''),
        orderNumber: String(raw.orderNumber ?? ''),
        status:      String(raw.status ?? ''),
        eventType:   (raw.eventType as OrderNotificationStatus) ?? 'ORDER_UPDATED',
        storeName:   String(raw.storeName ?? ''),
        totalAmount: Number(raw.totalAmount ?? 0),
        updatedAt:   String(raw.updatedAt ?? new Date().toISOString()),
        isRead:      false,
        receivedAt:  new Date().toISOString(),
      };

      setNotifications(prev => {
        const updated = [notification, ...prev].slice(0, MAX_NOTIFICATIONS);
        saveToStorage(updated);
        return updated;
      });

      playBeep();

      // Show toast for 4 seconds
      if (toastTimerRef.current) clearTimeout(toastTimerRef.current);
      setToast(notification);
      toastTimerRef.current = setTimeout(() => setToast(null), 4000);
    },
    []
  );

  // ── Initialise Mercure connection ──────────────────────────────────────────
  useEffect(() => {
    if (!isAuthenticated || !user) return;

    let unsubscribeFn: (() => void) | null = null;

    const init = async () => {
      // 1. Fetch subscriber JWT (fails silently — hub may allow anonymous in dev)
      try {
        const res    = await API.get<{ token: string; hubUrl: string }>('/api/mercure/token');
        const hubUrl = res.data.hubUrl || MERCURE_PUBLIC_URL;
        mercureService.configure(hubUrl, res.data.token);
      } catch {
        // No token available — configure with public hub URL (anonymous mode)
        mercureService.configure(MERCURE_PUBLIC_URL, null);
      }

      // 2. Register connection-state handler
      mercureService.setConnectionChangeHandler(setIsConnected);

      // 3. Subscribe to this user's topic
      const callback: MercureMessageCallback = data => addNotification(data);
      unsubscribeFn = mercureService.subscribe(topic, callback);
    };

    init();

    // Poll connection status every 4 s to keep indicator in sync
    statusPollRef.current = setInterval(() => {
      setIsConnected(mercureService.isConnected(topic));
    }, 4000);

    return () => {
      unsubscribeFn?.();
      if (statusPollRef.current)  clearInterval(statusPollRef.current);
      if (toastTimerRef.current) clearTimeout(toastTimerRef.current);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isAuthenticated, user?.id, topic]);

  // ── Actions ────────────────────────────────────────────────────────────────

  const markAllAsRead = useCallback(() => {
    setNotifications(prev => {
      const updated = prev.map(n => ({ ...n, isRead: true }));
      saveToStorage(updated);
      return updated;
    });
  }, []);

  const markAsRead = useCallback((id: string) => {
    setNotifications(prev => {
      const updated = prev.map(n => (n.id === id ? { ...n, isRead: true } : n));
      saveToStorage(updated);
      return updated;
    });
  }, []);

  const dismissToast = useCallback(() => {
    if (toastTimerRef.current) clearTimeout(toastTimerRef.current);
    setToast(null);
  }, []);

  return {
    notifications,
    unreadCount,
    isConnected,
    toast,
    markAllAsRead,
    markAsRead,
    dismissToast,
  };
}
