import React, { useState, useEffect } from "react";
import { Tag, message, Spin } from "antd";
import API from "../../services/httpClient";
import ChatModal from "../../components/Chat/ChatModal";

interface ClientOrder {
  id: string;
  orderNumber: string;
  totalPrice: string;
  status: string;
  paymentStatus: string;
  deliveryStatus: string;
  createdAt: string;
  store: { id: string; name: string };
}

const STATUS_COLORS: Record<string, string> = {
  pending:   "orange",
  completed: "green",
  cancelled: "red",
};

const STATUS_LABELS: Record<string, string> = {
  pending:   "En attente",
  completed: "Livré",
  cancelled: "Annulé",
  confirmed: "En préparation",
};

const ClientOrdersPage: React.FC = () => {
  const [orders, setOrders]         = useState<ClientOrder[]>([]);
  const [loading, setLoading]       = useState(true);
  const [chatOrderId, setChatOrderId]         = useState<string | null>(null);
  const [chatOrderNumber, setChatOrderNumber] = useState<string | undefined>();

  useEffect(() => {
    (async () => {
      try {
        const res = await API.get("/buyer/orders");
        setOrders(Array.isArray(res.data) ? res.data : (res.data?.data ?? []));
      } catch {
        message.error("Impossible de charger vos commandes.");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  if (loading) {
    return (
      <div style={{ display: "flex", justifyContent: "center", paddingTop: 64 }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div>
      <h1 style={{ fontSize: "1.5rem", fontWeight: 700, marginBottom: 24 }}>
        📦 Mes Commandes
      </h1>

      {orders.length === 0 ? (
        <div style={{ textAlign: "center", color: "#9ca3af", paddingTop: 48 }}>
          <div style={{ fontSize: 48 }}>📭</div>
          <p style={{ marginTop: 12 }}>Vous n'avez pas encore de commande.</p>
        </div>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {orders.map((order) => (
            <div
              key={order.id}
              style={{
                background: "#fff",
                border: "1px solid #f3f4f6",
                borderRadius: 12,
                padding: "16px 20px",
                boxShadow: "0 1px 3px rgba(0,0,0,0.05)",
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: 8 }}>
                <div>
                  <div style={{ fontWeight: 700, fontSize: "1rem", color: "#111827" }}>
                    Commande #{order.orderNumber}
                  </div>
                  <div style={{ fontSize: 13, color: "#6b7280", marginTop: 2 }}>
                    {order.store?.name} · {new Date(order.createdAt).toLocaleDateString("fr-CA")}
                  </div>
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <Tag color={STATUS_COLORS[order.status?.toLowerCase()] ?? "blue"}>
                    {STATUS_LABELS[order.status?.toLowerCase()] ?? order.status}
                  </Tag>
                  <span style={{ fontWeight: 600, color: "#F97316" }}>
                    ${parseFloat(order.totalPrice).toFixed(2)}
                  </span>
                </div>
              </div>

              <div style={{ marginTop: 14, display: "flex", gap: 10, flexWrap: "wrap" }}>
                <button
                  onClick={() => { setChatOrderId(order.id); setChatOrderNumber(order.orderNumber); }}
                  style={{
                    border: "1px solid #F97316",
                    color: "#F97316",
                    background: "transparent",
                    borderRadius: 8,
                    padding: "6px 14px",
                    cursor: "pointer",
                    fontSize: 13,
                    fontWeight: 500,
                  }}
                >
                  💬 Contacter le vendeur
                </button>
                <button
                  onClick={() => window.location.href = "/client/support"}
                  style={{
                    border: "1px solid #6b7280",
                    color: "#6b7280",
                    background: "transparent",
                    borderRadius: 8,
                    padding: "6px 14px",
                    cursor: "pointer",
                    fontSize: 13,
                  }}
                >
                  📧 Contacter le support
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {chatOrderId && (
        <ChatModal
          orderId={chatOrderId}
          orderNumber={chatOrderNumber}
          open={!!chatOrderId}
          onClose={() => { setChatOrderId(null); setChatOrderNumber(undefined); }}
        />
      )}
    </div>
  );
};

export default ClientOrdersPage;
