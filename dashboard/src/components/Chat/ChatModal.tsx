import React, { useState, useEffect, useRef, useCallback } from "react";
import { Modal, Input, Button, Spin, message as antdMessage } from "antd";
import { SendOutlined } from "@ant-design/icons";
import { ChatMessage, getMessages, sendMessage, markAsRead, subscribeToChat } from "../../services/chatService";
import { useAuth } from "../../contexts/AuthContext";

interface Props {
  orderId: string;
  orderNumber?: string;
  open: boolean;
  onClose: () => void;
}

export const ChatModal: React.FC<Props> = ({ orderId, orderNumber, open, onClose }) => {
  const { user } = useAuth();
  const currentUserId = (user as any)?.id ?? (user as any)?.userId ?? "";

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const loadMessages = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getMessages(orderId);
      setMessages(data);
      await markAsRead(orderId);
    } catch {
      // silent
    } finally {
      setLoading(false);
    }
  }, [orderId]);

  useEffect(() => {
    if (!open) return;
    loadMessages();
    const unsub = subscribeToChat(orderId, (msg) => {
      setMessages(prev => {
        if (prev.some(m => m.id === msg.id)) return prev;
        return [...prev, msg];
      });
      markAsRead(orderId).catch(() => {});
    });
    return unsub;
  }, [open, orderId, loadMessages]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSend = async () => {
    const trimmed = text.trim();
    if (!trimmed) return;
    setSending(true);
    try {
      await sendMessage(orderId, trimmed);
      setText("");
    } catch {
      antdMessage.error("Impossible d'envoyer le message.");
    } finally {
      setSending(false);
    }
  };

  const formatTime = (iso: string) => {
    try { return new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }); }
    catch { return ""; }
  };

  const initials = (name: string) =>
    name.split(" ").map(p => p[0]).join("").slice(0, 2).toUpperCase();

  return (
    <Modal
      open={open}
      onCancel={onClose}
      footer={null}
      title={
        <span style={{ color: "#F97316", fontWeight: 700 }}>
          💬 Chat — Commande #{orderNumber ?? orderId.slice(0, 8)}
        </span>
      }
      width={480}
      styles={{ body: { padding: 0 } }}
    >
      {/* Messages area */}
      <div
        style={{
          height: 400,
          overflowY: "auto",
          padding: "12px 16px",
          background: "#f9fafb",
          display: "flex",
          flexDirection: "column",
          gap: 10,
        }}
      >
        {loading ? (
          <div style={{ display: "flex", justifyContent: "center", alignItems: "center", height: "100%" }}>
            <Spin />
          </div>
        ) : messages.length === 0 ? (
          <div style={{ textAlign: "center", color: "#9ca3af", marginTop: 80, fontSize: 14 }}>
            Aucun message. Envoyez le premier message !
          </div>
        ) : (
          messages.map((msg) => {
            const isMine = msg.senderId === currentUserId;
            return (
              <div key={msg.id} style={{ display: "flex", justifyContent: isMine ? "flex-end" : "flex-start", alignItems: "flex-end", gap: 8 }}>
                {!isMine && (
                  <div style={{
                    width: 32, height: 32, borderRadius: "50%", background: "#e5e7eb",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: 12, fontWeight: 700, color: "#374151", flexShrink: 0,
                  }}>
                    {initials(msg.senderName)}
                  </div>
                )}
                <div style={{ maxWidth: "70%" }}>
                  <div style={{
                    background: isMine ? "#F97316" : "#ffffff",
                    color: isMine ? "#fff" : "#111827",
                    borderRadius: isMine ? "16px 16px 4px 16px" : "16px 16px 16px 4px",
                    padding: "8px 12px",
                    fontSize: 14,
                    boxShadow: "0 1px 2px rgba(0,0,0,0.08)",
                  }}>
                    {!isMine && <div style={{ fontSize: 11, fontWeight: 600, marginBottom: 2, color: "#6b7280" }}>{msg.senderName}</div>}
                    {msg.message}
                  </div>
                  <div style={{ fontSize: 10, color: "#9ca3af", marginTop: 2, textAlign: isMine ? "right" : "left" }}>
                    {formatTime(msg.createdAt)}
                  </div>
                </div>
                {isMine && (
                  <div style={{
                    width: 32, height: 32, borderRadius: "50%", background: "#F97316",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: 12, fontWeight: 700, color: "#fff", flexShrink: 0,
                  }}>
                    {initials((user as any)?.firstName ?? "M")}
                  </div>
                )}
              </div>
            );
          })
        )}
        <div ref={bottomRef} />
      </div>

      {/* Input area */}
      <div style={{ padding: "8px 12px", borderTop: "1px solid #e5e7eb", display: "flex", gap: 8, background: "#fff" }}>
        <Input
          value={text}
          onChange={e => setText(e.target.value)}
          onPressEnter={handleSend}
          placeholder="Écrivez un message..."
          disabled={sending}
          style={{ borderRadius: 20 }}
        />
        <Button
          type="primary"
          icon={<SendOutlined />}
          onClick={handleSend}
          loading={sending}
          disabled={!text.trim()}
          style={{ borderRadius: 20, background: "#F97316", borderColor: "#F97316" }}
        />
      </div>
    </Modal>
  );
};

export default ChatModal;
