// src/components/NotificationCenter.tsx
// Bell icon + dropdown + DoorDash-style toast popup.
// Colors and status labels match Uber Eats / DoorDash conventions.

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { useNotificationContext, OrderNotification, OrderNotificationStatus } from '../contexts/NotificationContext';

// ── Status config ─────────────────────────────────────────────────────────────

interface StatusConfig {
  label:      string;
  bgColor:    string;
  textColor:  string;
  dotColor:   string;
  emoji:      string;
}

const STATUS_CONFIG: Record<OrderNotificationStatus, StatusConfig> = {
  ORDER_CREATED:    { label: 'Nouvelle commande',   bgColor: 'bg-orange-50',  textColor: 'text-orange-700',  dotColor: 'bg-orange-500',  emoji: '🛍️' },
  ORDER_CONFIRMED:  { label: 'Commande confirmée',  bgColor: 'bg-blue-50',    textColor: 'text-blue-700',    dotColor: 'bg-blue-500',    emoji: '✅' },
  ORDER_PREPARING:  { label: 'En préparation',       bgColor: 'bg-yellow-50',  textColor: 'text-yellow-700',  dotColor: 'bg-yellow-500',  emoji: '👨‍🍳' },
  ORDER_READY:      { label: 'Prête',                bgColor: 'bg-green-50',   textColor: 'text-green-700',   dotColor: 'bg-green-500',   emoji: '✔️' },
  ORDER_PICKED_UP:  { label: 'Récupérée',            bgColor: 'bg-purple-50',  textColor: 'text-purple-700',  dotColor: 'bg-purple-500',  emoji: '🛵' },
  ORDER_DELIVERED:  { label: 'Livrée',               bgColor: 'bg-gray-50',    textColor: 'text-gray-500',    dotColor: 'bg-gray-400',    emoji: '📦' },
  ORDER_CANCELLED:  { label: 'Annulée',              bgColor: 'bg-red-50',     textColor: 'text-red-700',     dotColor: 'bg-red-500',     emoji: '❌' },
  ORDER_UPDATED:    { label: 'Mise à jour',          bgColor: 'bg-blue-50',    textColor: 'text-blue-600',    dotColor: 'bg-blue-400',    emoji: '🔄' },
  REFUND_COMPLETED: { label: 'Remboursement OK',     bgColor: 'bg-green-50',   textColor: 'text-green-600',   dotColor: 'bg-green-400',   emoji: '💚' },
  REFUND_FAILED:    { label: 'Remboursement échoué', bgColor: 'bg-red-50',     textColor: 'text-red-600',     dotColor: 'bg-red-400',     emoji: '🔴' },
};

function getConfig(eventType: OrderNotificationStatus): StatusConfig {
  return STATUS_CONFIG[eventType] ?? STATUS_CONFIG.ORDER_UPDATED;
}

// ── Relative time ─────────────────────────────────────────────────────────────

function relativeTime(iso: string): string {
  const diffMs  = Date.now() - new Date(iso).getTime();
  const diffMin = Math.floor(diffMs / 60_000);
  if (diffMin < 1)  return 'à l\'instant';
  if (diffMin < 60) return `il y a ${diffMin} min`;
  const diffH = Math.floor(diffMin / 60);
  if (diffH < 24)   return `il y a ${diffH} h`;
  return `il y a ${Math.floor(diffH / 24)} j`;
}

// ── Bell icon (heroicons outline) ─────────────────────────────────────────────

function BellIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
      <path strokeLinecap="round" strokeLinejoin="round"
        d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75v-.7V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" />
    </svg>
  );
}

// ── Single notification row ───────────────────────────────────────────────────

const NotificationRow: React.FC<{ notification: OrderNotification; onRead: (id: string) => void }> = ({
  notification,
  onRead,
}) => {
  const cfg = getConfig(notification.eventType);

  return (
    <button
      className={`w-full text-left px-4 py-3 flex gap-3 hover:bg-gray-50 transition-colors border-b border-gray-100 last:border-b-0 ${
        !notification.isRead ? 'bg-white' : 'bg-gray-50/50'
      }`}
      onClick={() => onRead(notification.id)}
    >
      {/* Status dot */}
      <div className="mt-1 flex-shrink-0">
        <span className="text-xl leading-none">{cfg.emoji}</span>
      </div>

      {/* Body */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className={`text-xs font-semibold px-1.5 py-0.5 rounded-full ${cfg.bgColor} ${cfg.textColor}`}>
            {cfg.label}
          </span>
          {!notification.isRead && (
            <span className="w-2 h-2 rounded-full bg-orange-500 flex-shrink-0" />
          )}
        </div>
        <p className="text-sm font-medium text-gray-800 truncate mt-0.5">
          {notification.orderNumber
            ? `Commande #${notification.orderNumber}`
            : `Commande ${notification.orderId.slice(0, 8)}…`}
        </p>
        <div className="flex items-center justify-between mt-0.5">
          <span className="text-xs text-gray-500 truncate">{notification.storeName}</span>
          <span className="text-xs text-gray-400 ml-2 flex-shrink-0">
            {notification.totalAmount > 0 ? `$${notification.totalAmount.toFixed(2)}` : ''}
          </span>
        </div>
        <span className="text-xs text-gray-400">{relativeTime(notification.receivedAt)}</span>
      </div>
    </button>
  );
};

// ── Toast popup (DoorDash style — bottom right) ───────────────────────────────

export const NotificationToast: React.FC = () => {
  const { toast, dismissToast } = useNotificationContext();

  if (!toast) return null;

  const cfg = getConfig(toast.eventType);

  return (
    <div
      className="fixed bottom-6 right-6 z-[9999] w-80 rounded-xl shadow-2xl border border-gray-200 bg-white overflow-hidden
                 animate-[slideInUp_0.3s_ease-out]"
      style={{
        animation: 'slideInUp 0.3s ease-out',
      }}
    >
      <style>{`
        @keyframes slideInUp {
          from { transform: translateY(100%); opacity: 0; }
          to   { transform: translateY(0);    opacity: 1; }
        }
      `}</style>

      {/* Coloured top bar */}
      <div className={`h-1 w-full ${cfg.dotColor}`} />

      <div className="p-4 flex gap-3 items-start">
        <span className="text-2xl leading-none">{cfg.emoji}</span>
        <div className="flex-1 min-w-0">
          <p className={`text-xs font-bold uppercase tracking-wide ${cfg.textColor}`}>{cfg.label}</p>
          <p className="text-sm font-semibold text-gray-800 truncate mt-0.5">
            {toast.orderNumber ? `Commande #${toast.orderNumber}` : 'Nouvelle notification'}
          </p>
          {toast.storeName && (
            <p className="text-xs text-gray-500 truncate">{toast.storeName}</p>
          )}
        </div>
        <button
          onClick={dismissToast}
          className="text-gray-400 hover:text-gray-600 transition-colors flex-shrink-0 mt-0.5"
          aria-label="Fermer"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
  );
};

// ── Main NotificationCenter component ────────────────────────────────────────

const NotificationCenter: React.FC = () => {
  const { notifications, unreadCount, isConnected, markAllAsRead, markAsRead } =
    useNotificationContext();

  const [isOpen, setIsOpen] = useState(false);
  const panelRef  = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);

  // Close on outside click
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (
        panelRef.current  && !panelRef.current.contains(e.target as Node) &&
        buttonRef.current && !buttonRef.current.contains(e.target as Node)
      ) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const toggle = useCallback(() => setIsOpen(prev => !prev), []);

  const handleMarkAllRead = useCallback(() => {
    markAllAsRead();
  }, [markAllAsRead]);

  return (
    <>
      {/* ── Bell button ── */}
      <div className="relative">
        <button
          ref={buttonRef}
          onClick={toggle}
          className="relative p-2 rounded-lg text-gray-500 hover:text-gray-800 hover:bg-gray-100 transition-colors focus:outline-none focus:ring-2 focus:ring-orange-400"
          aria-label={`Notifications${unreadCount > 0 ? ` (${unreadCount} non lues)` : ''}`}
        >
          <BellIcon className="w-6 h-6" />

          {/* Badge */}
          {unreadCount > 0 && (
            <span
              className="absolute -top-0.5 -right-0.5 min-w-[18px] h-[18px] px-1
                         flex items-center justify-center
                         rounded-full bg-red-500 text-white text-[10px] font-bold
                         animate-[pulse_1.5s_ease-in-out_infinite]"
              style={{ animation: 'pulse 1.5s ease-in-out infinite' }}
            >
              {unreadCount > 99 ? '99+' : unreadCount}
            </span>
          )}
        </button>

        {/* ── Dropdown panel ── */}
        {isOpen && (
          <div
            ref={panelRef}
            className="absolute right-0 mt-2 w-96 max-h-[480px] bg-white rounded-xl shadow-2xl border border-gray-200 z-50 flex flex-col overflow-hidden"
          >
            {/* Header */}
            <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100 flex-shrink-0">
              <div className="flex items-center gap-2">
                <h3 className="font-semibold text-gray-900 text-sm">Notifications</h3>
                {unreadCount > 0 && (
                  <span className="px-1.5 py-0.5 bg-orange-100 text-orange-700 text-xs font-bold rounded-full">
                    {unreadCount}
                  </span>
                )}
              </div>
              {unreadCount > 0 && (
                <button
                  onClick={handleMarkAllRead}
                  className="text-xs text-blue-600 hover:text-blue-800 font-medium transition-colors"
                >
                  Tout marquer comme lu
                </button>
              )}
            </div>

            {/* List */}
            <div className="overflow-y-auto flex-1">
              {notifications.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-12 text-gray-400">
                  <BellIcon className="w-10 h-10 mb-3 opacity-40" />
                  <p className="text-sm">Aucune notification</p>
                </div>
              ) : (
                notifications.map(n => (
                  <NotificationRow key={n.id} notification={n} onRead={markAsRead} />
                ))
              )}
            </div>

            {/* Footer — Live status */}
            <div className="px-4 py-2 border-t border-gray-100 flex-shrink-0 flex items-center gap-1.5">
              <span className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-500' : 'bg-gray-300'}`} />
              <span className="text-xs text-gray-500">
                {isConnected ? 'Connecté en temps réel' : 'Reconnexion…'}
              </span>
            </div>
          </div>
        )}
      </div>

      {/* ── Toast popup rendered via portal-like sibling ── */}
      <NotificationToast />
    </>
  );
};

export default NotificationCenter;
