import API from './httpClient';
import { mercureService } from './mercureService';

export interface ChatMessage {
  id: string;
  orderId: string;
  senderId: string;
  senderName: string;
  receiverId: string;
  message: string;
  isRead: boolean;
  createdAt: string;
}

// ── Demo-mode state (API unavailable) ─────────────────────────────────────────
// Once the first 404 is detected, all subsequent calls skip the API.
let _demoMode = false;

export function isChatDemoMode(): boolean {
  return _demoMode;
}

// ── localStorage helpers ───────────────────────────────────────────────────────
const STORAGE_KEY = (orderId: string) => `chat_demo_${orderId}`;

function loadLocal(orderId: string): ChatMessage[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY(orderId));
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveLocal(orderId: string, messages: ChatMessage[]): void {
  try {
    localStorage.setItem(STORAGE_KEY(orderId), JSON.stringify(messages));
  } catch {
    // storage full or private mode — ignore
  }
}

function buildDemoMessage(orderId: string, text: string): ChatMessage {
  const stored = localStorage.getItem("user");
  const user = stored ? (() => { try { return JSON.parse(stored); } catch { return {}; } })() : {};
  return {
    id: `demo_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    orderId,
    senderId: user.id ?? "local",
    senderName: [user.firstName, user.lastName].filter(Boolean).join(" ") || user.email || "Moi",
    receiverId: "",
    message: text,
    isRead: true,
    createdAt: new Date().toISOString(),
  };
}

// ── Public API ─────────────────────────────────────────────────────────────────

export async function getMessages(orderId: string): Promise<ChatMessage[]> {
  if (_demoMode) return loadLocal(orderId);
  try {
    const res = await API.get(`/chat/${orderId}`);
    return Array.isArray(res.data) ? res.data : [];
  } catch (err: any) {
    if (err?.response?.status === 404 || !err?.response) {
      _demoMode = true;
      return loadLocal(orderId);
    }
    throw err;
  }
}

export async function sendMessage(orderId: string, message: string): Promise<ChatMessage> {
  if (_demoMode) {
    const msg = buildDemoMessage(orderId, message);
    const existing = loadLocal(orderId);
    saveLocal(orderId, [...existing, msg]);
    return msg;
  }
  try {
    const res = await API.post(`/chat/${orderId}`, { message });
    return res.data;
  } catch (err: any) {
    if (err?.response?.status === 404 || !err?.response) {
      _demoMode = true;
      const msg = buildDemoMessage(orderId, message);
      const existing = loadLocal(orderId);
      saveLocal(orderId, [...existing, msg]);
      return msg;
    }
    throw err;
  }
}

export async function markAsRead(orderId: string): Promise<void> {
  if (_demoMode) return; // no-op in demo mode
  try {
    await API.put(`/chat/${orderId}/read`);
  } catch {
    // silent — non-critical
  }
}

/**
 * Subscribes to real-time chat messages via Mercure SSE.
 * In demo mode returns a no-op unsubscribe (messages are added directly by sendMessage).
 */
export function subscribeToChat(
  orderId: string,
  callback: (msg: ChatMessage) => void
): () => void {
  if (_demoMode) return () => {};
  try {
    return mercureService.subscribe(`/chat/${orderId}`, (data) => {
      callback(data as unknown as ChatMessage);
    });
  } catch {
    return () => {};
  }
}
