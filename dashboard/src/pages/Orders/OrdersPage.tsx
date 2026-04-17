import React, { useState, useEffect, useRef } from "react";
import { Table, Button, Space, Modal, message, Typography } from "antd";
import type { ColumnsType } from "antd/es/table";
import {
  fetchOrders,
  confirmOrder,
  cancelOrder,
  fetchOrderByIdForOrders,
} from "../../services/orderService";
import { Order } from "../../types/order";
import { useTranslation } from "react-i18next";
import { useNotificationContext } from "../../contexts/NotificationContext";
import EmptyState from "../../components/EmptyState";
import { SkeletonTableRows } from "../../components/SkeletonLoader";

const OrdersEmptyIcon = (
  <svg viewBox="0 0 64 64" fill="none" className="w-full h-full" stroke="currentColor">
    <rect x="14" y="8" width="36" height="48" rx="4" strokeWidth="3"/>
    <path strokeLinecap="round" strokeWidth="3" d="M22 20h20M22 30h20M22 40h12"/>
    <circle cx="46" cy="46" r="10" strokeWidth="3" fill="white"/>
    <path strokeLinecap="round" strokeWidth="3" d="M43 46h6M46 43v6"/>
  </svg>
);

const OrdersPage: React.FC = () => {
  const { t } = useTranslation();
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [fetchError, setFetchError] = useState<boolean>(false);
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [modalVisible, setModalVisible] = useState<boolean>(false);
  const [newOrderId, setNewOrderId] = useState<string | null>(null);
  const { Title } = Typography;

  const { latestNotification } = useNotificationContext();
  const prevLatestRef = useRef<string | null>(null);

  useEffect(() => {
    loadOrders();
  }, []);

  // React to incoming Mercure notifications — prepend new orders without full reload
  useEffect(() => {
    if (!latestNotification) return;
    if (latestNotification.id === prevLatestRef.current) return;
    prevLatestRef.current = latestNotification.id;

    // Only prepend on ORDER_CREATED events; other statuses just update existing row
    if (latestNotification.eventType === 'ORDER_CREATED') {
      fetchOrderByIdForOrders(latestNotification.orderId)
        .then((res) => {
          const newOrder: Order = res.data ?? res;
          setOrders(prev => {
            // Avoid duplicates
            if (prev.some(o => o.id === newOrder.id)) return prev;
            return [newOrder, ...prev];
          });
          setNewOrderId(newOrder.id);
          // Remove highlight after 3 s
          setTimeout(() => setNewOrderId(null), 3000);
        })
        .catch(() => {
          // Silent fallback — full reload if single-order fetch fails
          loadOrders();
        });
    }
  }, [latestNotification]);

  const loadOrders = async () => {
    try {
      setLoading(true);
      setFetchError(false);
      const response = await fetchOrders();
      const ordersData = Array.isArray(response.data) ? response.data : [];
      setOrders(ordersData);
    } catch (error) {
      console.error("Error fetching orders:", error);
      setFetchError(true);
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  const handleConfirm = async (id: string) => {
    try {
      await confirmOrder(id);
      message.success(t("orders.messages.confirmSuccess"));
      loadOrders();
    } catch (error) {
      message.error(t("orders.messages.confirmError"));
    }
  };

  const handleCancel = async (id: string) => {
    try {
      await cancelOrder(id);
      message.success(t("orders.messages.cancelSuccess"));
      loadOrders();
    } catch (error) {
      message.error(t("orders.messages.cancelError"));
    }
  };

  const showOrderDetails = (order: Order) => {
    setSelectedOrder(order);
    setModalVisible(true);
    document.body.style.overflow = "hidden";
  };

  const handleCloseModal = () => {
    setModalVisible(false);
    document.body.style.overflow = "auto";
  };

  const columns: ColumnsType<Order> = [
    {
      title: t("orders.table.columns.orderNumber"),
      dataIndex: "orderNumber",
      key: "orderNumber",
    },
    {
      title: t("orders.table.columns.customer"),
      dataIndex: "buyerFullName",
      key: "buyerFullName",
    },
    {
      title: t("orders.table.columns.store"),
      dataIndex: "storeName",
      key: "storeName",
    },
    {
      title: t("orders.table.columns.totalPrice"),
      dataIndex: "totalPrice",
      key: "totalPrice",
      render: (price: string) => `${parseFloat(price).toFixed(2)}`,
    },

    {
      title: t("orders.table.columns.grossTotal"),
      dataIndex: "grossTotal",
      key: "grossTotal",
      render: (price: string) => `${parseFloat(price).toFixed(2)}`,
    },
    {
      title: t("orders.table.columns.status"),
      dataIndex: "status",
      key: "status",
      render: (status: string) => (
        <span
          style={{
            color:
              status === "completed"
                ? "green"
                : status === "cancelled"
                  ? "red"
                  : "orange",
          }}
        >
          {t(`orders.table.status.${status}`)}
        </span>
      ),
    },
    {
      title: t("orders.table.columns.date"),
      dataIndex: "createdAt",
      key: "createdAt",
      render: (date: string) => new Date(date).toLocaleString(),
    },
    {
      title: t("orders.table.columns.actions"),
      key: "actions",
      render: (_: any, record: Order) => (
        <Space size="middle">
          <Button type="link" onClick={() => showOrderDetails(record)}>
            {t("orders.actions.view")}
          </Button>
          {record.status === "pending" && (
            <>
              <Button type="primary" onClick={() => handleConfirm(record.id)}>
                {t("orders.actions.confirm")}
              </Button>
              <Button danger onClick={() => handleCancel(record.id)}>
                {t("orders.actions.cancel")}
              </Button>
            </>
          )}
        </Space>
      ),
    },
  ];

  if (loading) {
    return (
      <div style={{ padding: "20px" }}>
        <div style={{ height: 32, width: 180, background: "#f0f0f0", borderRadius: 6, marginBottom: 16 }} />
        <SkeletonTableRows rows={8} />
      </div>
    );
  }

  if (fetchError) {
    return (
      <EmptyState
        icon={OrdersEmptyIcon}
        title="Aucune commande disponible"
        description="Impossible de charger les commandes. Le serveur ne répond pas."
        onRetry={loadOrders}
      />
    );
  }

  return (
    <div style={{ padding: "20px", width: "100%", maxWidth: "100%", overflow: "hidden" }}>
      <style>{`
        @keyframes slideInDown {
          from { transform: translateY(-12px); opacity: 0; background-color: #fff7ed; }
          to   { transform: translateY(0);     opacity: 1; }
        }
        .order-row-new td { animation: slideInDown 0.4s ease-out; background-color: #fff7ed !important; }
      `}</style>
      <Title level={2}>{t("rating.admin.title")}</Title>
      <Table
        columns={columns}
        dataSource={orders}
        rowKey="id"
        loading={loading}
        style={{"overflowX":"scroll"}}
        pagination={{ pageSize: 10 }}
        rowClassName={(record) => record.id === newOrderId ? 'order-row-new' : ''}
        locale={{
          emptyText: t("orders.table.emptyText"),
        }}
      />

      <Modal
        title={t("orders.modal.title")}
        open={modalVisible}
        onCancel={handleCloseModal}
        footer={null}
        centered
      >
        {selectedOrder && (
          <div>
            <h3>{t("orders.modal.orderInfo")}</h3>
            <p>
              <strong>{t("orders.modal.fields.orderNumber")}:</strong>
              {selectedOrder.orderNumber}
            </p>
            <p>
              <strong>{t("orders.modal.fields.customer")}:</strong>
              {selectedOrder.buyerFullName}
            </p>
            <p>
              <strong>{t("orders.modal.fields.store")}:</strong>
              {selectedOrder.storeName}
            </p>

            <h3 style={{ marginTop: 16 }}><strong>{t("orders.modal.taxesInfo")}</strong></h3>
            <div style={{ marginBottom: 16 }}>
              <p><strong>{t("orders.modal.taxes.rates")}:</strong></p>
              <ul style={{ marginLeft: 20 }}>
                <li>TPS: {selectedOrder.appliedTaxes.rates.TPS} ({(parseFloat(selectedOrder.appliedTaxes.rates.TPS) * 100).toFixed(2)}%)</li>
                <li>TVQ: {selectedOrder.appliedTaxes.rates.TVQ} ({(parseFloat(selectedOrder.appliedTaxes.rates.TVQ) * 100).toFixed(2)}%)</li>
              </ul>
              <p><strong>{t("orders.modal.taxes.amounts")}:</strong></p>
              <ul style={{ marginLeft: 20 }}>
                <li>TPS: ${selectedOrder.appliedTaxes.amounts.TPS.amount}</li>
                <li>TVQ: ${selectedOrder.appliedTaxes.amounts.TVQ.amount}</li>
              </ul>
              <p><strong>{t("orders.modal.taxes.totalTax")}:</strong> $
                {(parseFloat(selectedOrder.appliedTaxes.amounts.TPS.amount) + parseFloat(selectedOrder.appliedTaxes.amounts.TVQ.amount)).toFixed(2)}
              </p>

              <p>
                <strong>{t("orders.modal.fields.totalPrice")}:</strong> $
                {selectedOrder.totalPrice}
              </p>

              <p>
                <strong>{t("orders.modal.fields.grossTotal")}:</strong> $
                {selectedOrder.grossTotal}
              </p>
            </div>

            <h3 style={{ marginTop: 16 }}>{t("orders.modal.statusInfo")}</h3>
            <p>
              <strong>{t("orders.modal.fields.orderStatus")}:</strong>{" "}
              {selectedOrder.status}
            </p>
            <p>
              <strong>{t("orders.modal.fields.paymentStatus")}:</strong>{" "}
              {selectedOrder.paymentStatus}
            </p>
            <p>
              <strong>{t("orders.modal.fields.deliveryStatus")}:</strong>{" "}
              {selectedOrder.deliveryStatus}
            </p>
          </div>
        )}
      </Modal>
    </div>
  );
};
export default OrdersPage;
