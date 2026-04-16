import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Modal, message, Tag, Typography } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import { useTranslation } from 'react-i18next';
import { fetchAdminOrders, fetchAdminOrderById, cancelAdminOrder } from '../../services/adminOrderService';
import { AdminOrder } from '../../types/adminOrder';

const { Title } = Typography;

const AdminOrdersPage: React.FC = () => {
  const { t } = useTranslation();
  const [orders, setOrders] = useState<AdminOrder[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [selectedOrder, setSelectedOrder] = useState<AdminOrder | null>(null);
  const [modalVisible, setModalVisible] = useState<boolean>(false);
  const [modalLoading, setModalLoading] = useState<boolean>(false);

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    try {
      setLoading(true);
      const response = await fetchAdminOrders();
      
      const ordersData = Array.isArray(response.data) ? response.data : [];
      setOrders(ordersData);
    } catch (error) {
      console.error("Error fetching admin orders:", error);
      message.error(t('adminOrders.fetchError'));
      setOrders([]);
    } finally {
      setLoading(false);
    }
  };

  const showOrderDetails = async (id: string) => {
    try {
      setModalLoading(true);
      const order = await fetchAdminOrderById(id);
      setSelectedOrder(order);
      
      setModalVisible(true);
    } catch (error) {
      message.error(t('adminOrders.detailsError'));
    } finally {
      setModalLoading(false);
    }
  };

  const handleCancelOrder = async (order: AdminOrder) => {
    // Check if order can be cancelled
    const status = order.status.toLowerCase();
    const deliveryStatus = order.deliveryStatus.toLowerCase();
    
    if (status === 'completed') {
      message.error(t('adminOrders.cannotCancelCompleted'));
      return;
    }
    
    if (deliveryStatus === 'in transit' || deliveryStatus === 'delivered') {
      message.error(deliveryStatus === 'in transit' 
        ? t('adminOrders.cannotCancelInTransit') 
        : t('adminOrders.cannotCancelDelivered'));
      return;
    }

    Modal.confirm({
      title: t('adminOrders.cancelOrder'),
      content: t('adminOrders.cancelOrderConfirm'),
      okText: "Ok",
      okType: 'danger',
      cancelText: t('common.cancel'),
      onOk: async () => {
        try {
          await cancelAdminOrder(order.id);
          message.success(t('adminOrders.cancelOrderSuccess'));
          // Refresh orders list
          loadOrders();
          // Close modal if it's open
          if (modalVisible) {
            setModalVisible(false);
          }
        } catch (error) {
          console.error("Error cancelling order:", error);
          message.error(t('adminOrders.cancelOrderError'));
        }
      },
    });
  };

  const canCancelOrder = (order: AdminOrder) => {
    const status = order.status.toLowerCase();
    const deliveryStatus = order.deliveryStatus.toLowerCase();
    
    return status !== 'completed' && 
           status !== 'cancelled' && 
           deliveryStatus !== 'in transit' && 
           deliveryStatus !== 'delivered';
  };

  const getStatusTag = (status: string) => {
    let color = '';
    switch (status.toLowerCase()) {
      case 'completed':
        color = 'green';
        break;
      case 'cancelled':
        color = 'red';
        break;
      case 'pending':
        color = 'orange';
        break;
      default:
        color = 'blue';
    }
    return <Tag color={color}>{t(`adminOrders.status.${status.toLowerCase()}`)}</Tag>;
  };

  const columns: ColumnsType<AdminOrder> = [
    {
      title: t('adminOrders.columns.orderNumber'),
      dataIndex: 'orderNumber',
      key: 'orderNumber',
      sorter: (a, b) => a.orderNumber.localeCompare(b.orderNumber),
    },
    {
      title: t('adminOrders.columns.customer'),
      dataIndex: 'buyerFullName',
      key: 'buyerFullName',
      sorter: (a, b) => a.buyer.fullName.localeCompare(b.buyer.fullName),
    },
    {
      title: t('adminOrders.columns.store'),
      dataIndex: 'storeName',
      key: 'storeName',
      sorter: (a, b) => a.store.name.localeCompare(b.store.name),
    },
    {
      title: t('adminOrders.columns.totalPrice'),
      dataIndex: 'totalPrice',
      key: 'totalPrice',
      render: (price: string) => `$${parseFloat(price).toFixed(2)}`,
      sorter: (a, b) => parseFloat(a.totalPrice) - parseFloat(b.totalPrice),
    },
    {
      title: t('adminOrders.columns.status'),
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => getStatusTag(status),
      filters: [
        { text: t('adminOrders.status.pending'), value: 'pending' },
        { text: t('adminOrders.status.completed'), value: 'completed' },
        { text: t('adminOrders.status.cancelled'), value: 'cancelled' },
      ],
      onFilter: (value, record) => record.status.toLowerCase() === value.toString().toLowerCase(),
    },
    {
      title: t('adminOrders.columns.date'),
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => new Date(date).toLocaleString(),
      sorter: (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
    },
    {
      title: t('adminOrders.columns.actions'),
      key: 'actions',
      render: (_: any, record: AdminOrder) => (
        <Space size="middle">
          <Button 
            type="link" 
            onClick={() => showOrderDetails(record.id)}
          >
            {t('adminOrders.viewDetails')}
          </Button>
          {canCancelOrder(record) && (
            <Button 
              type="link" 
              danger
              onClick={() => handleCancelOrder(record)}
            >
              {t('adminOrders.cancel')}
            </Button>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: '20px' }}>
      <Title level={2}>{t('adminOrders.title')}</Title>
      <Table
        columns={columns}
        dataSource={orders}
        rowKey="id"
        loading={loading}
        pagination={{
          pageSize: 10,
          showSizeChanger: true,
          pageSizeOptions: ['10', '20', '50', '100'],
        }}
        bordered
        scroll={{ x: true }}
        locale={{
          emptyText: t('adminOrders.noOrders')
        }}
      />

      <Modal
        title={`${t('adminOrders.orderDetails')}: ${selectedOrder?.orderNumber || ''}`}
        open={modalVisible}
        onCancel={() => setModalVisible(false)}
        footer={null}
        width={800}
        confirmLoading={modalLoading}
      >
        {selectedOrder && (
          <div>
            <div style={{ marginBottom: '16px' }}>
              <h3>{t('adminOrders.orderInfo')}</h3>
              <p><strong>{t('adminOrders.orderNumber')}:</strong> {selectedOrder.orderNumber}</p>
              <p><strong>{t('adminOrders.confirmationCode')}:</strong> {selectedOrder.confirmationCode}</p>
              <p><strong>{t('adminOrders.totalPrice')}:</strong> ${parseFloat(selectedOrder.totalPrice).toFixed(2)}</p>
            </div>

            <div style={{ marginBottom: '16px' }}>
              <h3>{t('adminOrders.customerInfo')}</h3>
              <p><strong>{t('adminOrders.customerName')}:</strong> {selectedOrder.buyer.fullName}</p>
              <p><strong>{t('adminOrders.customerId')}:</strong> {selectedOrder.buyer.id}</p>
            </div>

            <div style={{ marginBottom: '16px' }}>
              <h3>{t('adminOrders.storeInfo')}</h3>
              <p><strong>{t('adminOrders.storeName')}:</strong> {selectedOrder.store.name}</p>
              <p><strong>{t('adminOrders.storeId')}:</strong> {selectedOrder.store.id}</p>
            </div>

            <div style={{ marginBottom: '16px' }}>
              <h3>{t('adminOrders.statusInfo')}</h3>
              <p><strong>{t('adminOrders.orderStatus')}:</strong> {getStatusTag(selectedOrder.status)}</p>
              <p><strong>{t('adminOrders.paymentStatus')}:</strong> {getStatusTag(selectedOrder.paymentStatus)}</p>
              <p><strong>{t('adminOrders.deliveryStatus')}:</strong> {getStatusTag(selectedOrder.deliveryStatus)}</p>
            </div>

            <div>
              <h3>{t('adminOrders.timestamps')}</h3>
              <p><strong>{t('adminOrders.createdAt')}:</strong> {new Date(selectedOrder.createdAt).toLocaleString()}</p>
              {selectedOrder.updatedAt && (
                <p><strong>{t('adminOrders.lastUpdated')}:</strong> {new Date(selectedOrder.updatedAt).toLocaleString()}</p>
              )}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default AdminOrdersPage;