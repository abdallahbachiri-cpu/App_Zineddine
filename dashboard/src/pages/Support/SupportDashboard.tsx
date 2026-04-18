import React, { useState, useEffect } from "react";
import { Badge, Spin, message } from "antd";
import API from "../../services/httpClient";
import { useAuth } from "../../contexts/AuthContext";
import { useNavigate } from "react-router-dom";
import ChatModal from "../../components/Chat/ChatModal";
import logo from "../../assets/logo.svg";

interface Conversation {
  orderId: string;
  orderNumber: string;
  status: string;
  buyerId: string;
  buyerFirst: string;
  buyerLast: string;
  sellerId: string;
  sellerFirst: string;
  sellerLast: string;
  messageCount: number;
  unreadCount: number;
  lastMessageAt: string;
}

const SupportDashboard: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading]             = useState(true);
  const [filter, setFilter]               = useState<"all" | "unread">("all");
  const [chatOrderId, setChatOrderId]     = useState<string | null>(null);
  const [chatOrderNum, setChatOrderNum]   = useState<string | undefined>();

  useEffect(() => {
    (async () => {
      try {
        const res = await API.get("/support/conversations");
        setConversations(Array.isArray(res.data) ? res.data : []);
      } catch {
        message.error("Impossible de charger les conversations.");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const visible = filter === "unread"
    ? conversations.filter(c => Number(c.unreadCount) > 0)
    : conversations;

  const totalUnread = conversations.reduce((sum, c) => sum + Number(c.unreadCount), 0);

  const handleLogout = async () => { await logout(); navigate("/login"); };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Header */}
      <header style={{ background: "#fff", borderBottom: "1px solid #f3f4f6", padding: "0 24px", height: 64, display: "flex", alignItems: "center", justifyContent: "space-between", position: "sticky", top: 0, zIndex: 50, boxShadow: "0 1px 3px rgba(0,0,0,0.04)" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <img src={logo} alt="Cuisinous" style={{ width: 36, height: 36 }} />
          <div>
            <div style={{ fontWeight: 700, fontSize: "1rem", color: "#111827", lineHeight: 1.2 }}>Support Cuisinous</div>
            <div style={{ fontSize: 11, color: "#9ca3af" }}>Tableau de bord support</div>
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
          <span style={{ fontSize: 13, color: "#6b7280" }}>{(user as any)?.firstName} {(user as any)?.lastName}</span>
          <button onClick={handleLogout} style={{ background: "none", border: "1px solid #e5e7eb", borderRadius: 8, padding: "6px 14px", cursor: "pointer", fontSize: 13 }}>Déconnexion</button>
        </div>
      </header>

      <div style={{ maxWidth: 960, margin: "32px auto", padding: "0 24px", width: "100%" }}>
        {/* Stats row */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 16, marginBottom: 28 }}>
          {[
            { label: "Conversations", value: conversations.length, icon: "💬" },
            { label: "Non lus",       value: totalUnread,           icon: "🔴" },
            { label: "Vendeurs actifs", value: new Set(conversations.map(c => c.sellerId)).size, icon: "🏪" },
          ].map(stat => (
            <div key={stat.label} style={{ background: "#fff", borderRadius: 12, padding: "20px 24px", border: "1px solid #f3f4f6", boxShadow: "0 1px 3px rgba(0,0,0,0.05)" }}>
              <div style={{ fontSize: 28, marginBottom: 6 }}>{stat.icon}</div>
              <div style={{ fontSize: "1.6rem", fontWeight: 800, color: "#111827" }}>{stat.value}</div>
              <div style={{ fontSize: 13, color: "#6b7280" }}>{stat.label}</div>
            </div>
          ))}
        </div>

        {/* Filter tabs */}
        <div style={{ display: "flex", gap: 8, marginBottom: 20 }}>
          {(["all", "unread"] as const).map(f => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              style={{ padding: "7px 18px", borderRadius: 8, border: "1.5px solid", cursor: "pointer", fontWeight: 600, fontSize: 13,
                borderColor: filter === f ? "#F97316" : "#e5e7eb",
                background:  filter === f ? "#fff7f0" : "#fff",
                color:       filter === f ? "#F97316" : "#374151",
              }}
            >
              {f === "all" ? "Toutes" : `Non lus${totalUnread > 0 ? ` (${totalUnread})` : ""}`}
            </button>
          ))}
        </div>

        {/* Conversation list */}
        {loading ? (
          <div style={{ textAlign: "center", paddingTop: 48 }}><Spin size="large" /></div>
        ) : visible.length === 0 ? (
          <div style={{ textAlign: "center", color: "#9ca3af", paddingTop: 48 }}>
            <div style={{ fontSize: 48 }}>📭</div>
            <p style={{ marginTop: 12 }}>Aucune conversation trouvée.</p>
          </div>
        ) : (
          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            {visible.map(conv => (
              <div key={conv.orderId} style={{ background: "#fff", borderRadius: 12, padding: "16px 20px", border: `1px solid ${Number(conv.unreadCount) > 0 ? "#fed7aa" : "#f3f4f6"}`, boxShadow: "0 1px 3px rgba(0,0,0,0.05)", display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 12 }}>
                <div style={{ flex: 1 }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
                    <span style={{ fontWeight: 700, color: "#111827" }}>#{conv.orderNumber}</span>
                    {Number(conv.unreadCount) > 0 && (
                      <Badge count={Number(conv.unreadCount)} style={{ backgroundColor: "#F97316" }} />
                    )}
                  </div>
                  <div style={{ fontSize: 13, color: "#6b7280" }}>
                    <span>🛒 {conv.buyerFirst} {conv.buyerLast}</span>
                    <span style={{ margin: "0 8px" }}>→</span>
                    <span>🏪 {conv.sellerFirst} {conv.sellerLast}</span>
                  </div>
                  <div style={{ fontSize: 12, color: "#9ca3af", marginTop: 2 }}>
                    {conv.messageCount} message{Number(conv.messageCount) !== 1 ? "s" : ""} · Dernier : {new Date(conv.lastMessageAt).toLocaleString("fr-CA")}
                  </div>
                </div>
                <button
                  onClick={() => { setChatOrderId(conv.orderId); setChatOrderNum(conv.orderNumber); }}
                  style={{ background: "#F97316", color: "#fff", border: "none", borderRadius: 8, padding: "8px 16px", cursor: "pointer", fontWeight: 600, fontSize: 13, flexShrink: 0 }}
                >
                  💬 Ouvrir
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {chatOrderId && (
        <ChatModal
          orderId={chatOrderId}
          orderNumber={chatOrderNum}
          open={!!chatOrderId}
          onClose={() => { setChatOrderId(null); setChatOrderNum(undefined); }}
        />
      )}
    </div>
  );
};

export default SupportDashboard;
