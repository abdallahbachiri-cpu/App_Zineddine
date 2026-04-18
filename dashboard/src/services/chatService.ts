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

export async function getMessages(orderId: string): Promise<ChatMessage[]> {
  const res = await API.get(`/chat/${orderId}`);
  return Array.isArray(res.data) ? res.data : [];
}

export async function sendMessage(orderId: string, message: string): Promise<ChatMessage> {
  const res = await API.post(`/chat/${orderId}`, { message });
  return res.data;
}

export async function markAsRead(orderId: string): Promise<void> {
  await API.put(`/chat/${orderId}/read`);
}

/**
 * Subscribes to real-time chat messages via Mercure SSE.
 * Returns an unsubscribe function.
 */
export function subscribeToChat(
  orderId: string,
  callback: (msg: ChatMessage) => void
): () => void {
  return mercureService.subscribe(`/chat/${orderId}`, (data) => {
    callback(data as unknown as ChatMessage);
  });
}
