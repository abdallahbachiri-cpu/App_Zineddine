import { useState, useEffect } from "react";
import { 
  Card, 
  Row, 
  Col, 
  Table, 
  Spin,
  Statistic,
  Typography,
  Tag,
  Progress,
  Select,
  Space,
  Button
} from "antd";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from "recharts";
import {
  DollarOutlined,
  UserOutlined,
  ShopOutlined,
  CheckCircleOutlined,
  OrderedListOutlined,
  ReloadOutlined
} from "@ant-design/icons";
import API from '../../services/httpClient';
import { getAdminBasicStats, getAdminRevenueByYear, getAdminRevenueByMonth, getAdminRevenueByDay } from "../../services/analyticsService";
import { useTranslation } from "react-i18next";
import { Link } from "react-router-dom";

const { Title, Text } = Typography;
const { Option } = Select;

interface Order {
  id: string;
  orderNumber: string;
  totalAmount: number;
  status: OrderStatus;
  createdAt: string;
  buyer: {
    firstName: string;
    lastName: string;
  };
}

type OrderStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled';

const AdminStatistics = () => {
  const { t } = useTranslation();
  const [loading, setLoading] = useState(true);
  const [revenueLoading, setRevenueLoading] = useState(false);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [revenueView, setRevenueView] = useState<'year' | 'month' | 'day'>('month');
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeUsers: 0,
    totalFoodStores: 0,
    verifiedFoodStores: 0,
    totalOrders: 0,
    completedOrders: 0,
    totalRevenue: 0,
    recentOrders: [] as Order[],
    yearlyRevenue: [] as { year: string; revenue: number }[],
    monthlyRevenueByYear: [] as { month: string; revenue: number }[],
    dailyRevenueByMonth: [] as { day: string; revenue: number }[]
  });

  const fetchRevenueData = async () => {
    try {
      setRevenueLoading(true);
      
      if (revenueView === 'year') {
        const response = await getAdminRevenueByYear();

        const dataObj = response?.revenueByYear || response || {}; 
        const yearlyData = Object.keys(dataObj).map(year => ({
          year: year,
          revenue: parseFloat(dataObj[year]) || 0
        }));
        
        setStats(prev => ({ ...prev, yearlyRevenue: yearlyData }));

      } else if (revenueView === 'month') {
        const response = await getAdminRevenueByMonth(selectedYear);
        const dataObj = response?.revenueByMonth || response || {};
        const monthlyData = Object.keys(dataObj).map(month => ({
          month: month,
          revenue: parseFloat(dataObj[month]) || 0
        }));

        setStats(prev => ({ ...prev, monthlyRevenueByYear: monthlyData }));

      } else if (revenueView === 'day') {
        const response = await getAdminRevenueByDay(selectedYear, selectedMonth);
        const dailyData = response?.revenueByDay 
          ? Object.keys(response.revenueByDay).map(day => ({
              day: day,
              revenue: parseFloat(response.revenueByDay[day]) || 0
            }))
          : [];

        setStats(prev => ({ ...prev, dailyRevenueByMonth: dailyData }));
      }
    } catch (error) {
      console.error("Failed to fetch revenue data:", error);
    } finally {
      setRevenueLoading(false);
    }
  };

  useEffect(() => {
    fetchRevenueData();
  }, [revenueView, selectedYear, selectedMonth]);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setLoading(true);
        
        const basicStats = await getAdminBasicStats();
        
        const [
          ordersRes, 
          dishesRes,
          foodStoresRes
        ] = await Promise.all([
          API.get('/admin/orders'),
          API.get('/admin/dishes'),
          API.get('/admin/food-stores'),
        ]);

        const orders = ordersRes.data.data || [];
        const dishes = dishesRes.data || [];
        const totalUsers = basicStats?.totalUsers || 0;
        const activeUsers = basicStats?.activeUsers || totalUsers;
        const totalFoodStores = foodStoresRes.data.data.length || [];
        const verifiedFoodStores = foodStoresRes.data.data.filter((store: any) => store.vendorAgreementAccepted).length;
        const totalOrders = basicStats?.totalOrders || orders.length;
        const completedOrders = basicStats?.completedOrders || orders.filter((o: { status: string; }) => o.status === 'completed').length;
        const totalRevenue = basicStats?.totalRevenue || 0;
        
        const recentOrders = orders
          .sort((a: Order, b: Order) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
          .slice(0, 5);
        
        setStats(prev => ({
          ...prev,
          totalUsers,
          activeUsers,
          totalFoodStores,
          verifiedFoodStores,
          totalOrders,
          completedOrders,
          totalRevenue,
          recentOrders,
          dishes,
        }));
      } catch (error) {
        console.error("Failed to fetch stats:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  const columns = [
    {
      title: t('admin.orderId'),
      dataIndex: 'orderNumber',
      key: 'orderNumber',
      render: (text: string) => <Text copyable>{text.substring(0, 8)}...</Text>
    },
    {
      title: t('admin.buyer'),
      dataIndex: ["buyer", "firstName"],
      key: 'buyer',
      render: (_: any, record: any) => `${record.buyerFullName || `${record.buyer?.firstName} ${record.buyer?.lastName}`}`
    },
    {
      title: t('admin.store'),
      dataIndex: "storeName",
      key: "storeName",
    },
    {
      title: t('admin.amount'),
      dataIndex: 'totalPrice',
      key: 'totalPrice',
      render: (totalPrice: number) => `${totalPrice}`
    },
    {
      title: t('admin.status.title'),
      dataIndex: 'status',
      key: 'status',
      render: (status: OrderStatus) => {
        const statusMap = {
          pending: { color: 'gold', text: t('admin.status.pending') },
          confirmed: { color: 'blue', text: t('admin.status.confirmed') },
          completed: { color: 'green', text: t('admin.status.completed') },
          cancelled: { color: 'red', text: t('admin.status.cancelled') }
        };
        return <Tag color={statusMap[status]?.color || 'default'}>{statusMap[status]?.text || status}</Tag>;
      }
    },
    {
      title: t('adminOrders.columns.date'),
      dataIndex: 'createdAt',
      key: 'date',
      render: (date: string) => new Date(date).toLocaleDateString()
    }
  ];

  const getRevenueData = () => {
    switch (revenueView) {
      case 'year':
        return stats.yearlyRevenue;
      case 'month':
        return stats.monthlyRevenueByYear;
      case 'day':
        return stats.dailyRevenueByMonth;
      default:
        return [];
    }
  };

  const getRevenueChartTitle = () => {
    switch (revenueView) {
      case 'year':
        return 'Platform Revenue by Year';
      case 'month':
        return `Platform Revenue by Month - ${selectedYear}`;
      case 'day':
        return `Platform Revenue by Day - ${selectedMonth}/${selectedYear}`;
      default:
        return 'Platform Revenue';
    }
  };

  const getRevenueXAxisKey = () => {
    switch (revenueView) {
      case 'year':
        return 'year';
      case 'month':
        return 'month';
      case 'day':
        return 'day';
      default:
        return 'date';
    }
  };

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
        <Spin size="large" tip={t('admin.loading')} />
      </div>
    );
  }

  return (
    <div style={{ padding: 24 }}>
      <Title level={3} style={{ marginBottom: 24 }}>{t('admin.statistics.title')}</Title>
      
      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Link to="/">
              <Statistic
                title={t('admin.totalUsers')}
                value={stats.totalUsers}
                prefix={<UserOutlined />}
              />
            </Link>
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Link to="/">
              <Statistic
                title={t('admin.activeUsers')}
                value={stats.activeUsers}
                prefix={<UserOutlined />}
              />
            </Link>
            
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Link to="/admin/food-stores">
              <Statistic
                title={t('admin.foodStores')}
                value={stats.totalFoodStores}
                prefix={<ShopOutlined />}
              />
            </Link>
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Link to="/admin/food-stores">
            <Statistic
              title={t('admin.verifiedStores')}
              value={stats.verifiedFoodStores}
              prefix={<ShopOutlined />}
            />
            </Link>
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col xs={24} sm={12} md={8}>
          <Card bordered={false}>
            <Link to="/admin/orders">
              <Statistic
                title={t('admin.totalOrders')}
                value={stats.totalOrders}
                prefix={<OrderedListOutlined />}
              />
            </Link>
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8}>
          <Card bordered={false}>
            <Link to="/admin/orders">
              <Statistic
                title={t('admin.completedOrders')}
                value={stats.completedOrders}
                prefix={<CheckCircleOutlined />}
              />
            </Link>
            <Progress 
              percent={Math.round((stats.completedOrders / stats.totalOrders) * 100)} 
              size="small" 
              status="active" 
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8}>
          <Card bordered={false}>
            <Statistic
              title={t('admin.totalRevenue')}
              value={stats.totalRevenue}
              precision={2}
              prefix={<DollarOutlined />}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col xs={24} lg={12}>
          <Card 
            title={getRevenueChartTitle()} 
            extra={
              <Space>
                <Select
                  value={revenueView}
                  onChange={setRevenueView}
                  style={{ width: 120 }}
                >
                  <Option value="year">{t('statistics.yearly')}</Option>
                  <Option value="month">{t('statistics.monthly')}</Option>
                  <Option value="day">{t('statistics.daily')}</Option>
                </Select>
                {revenueView === 'month' && (
                  <Select
                    value={selectedYear}
                    onChange={setSelectedYear}
                    style={{ width: 100 }}
                  >
                    {Array.from({ length: 5 }, (_, i) => (
                      <Option key={new Date().getFullYear() - i} value={new Date().getFullYear() - i}>
                        {new Date().getFullYear() - i}
                      </Option>
                    ))}
                  </Select>
                )}
                {revenueView === 'day' && (
                  <>
                    <Select
                      value={selectedYear}
                      onChange={setSelectedYear}
                      style={{ width: 100 }}
                    >
                      {Array.from({ length: 5 }, (_, i) => (
                        <Option key={new Date().getFullYear() - i} value={new Date().getFullYear() - i}>
                          {new Date().getFullYear() - i}
                        </Option>
                      ))}
                    </Select>
                    <Select
                      value={selectedMonth}
                      onChange={setSelectedMonth}
                      style={{ width: 100 }}
                    >
                      {Array.from({ length: 12 }, (_, i) => (
                        <Option key={i + 1} value={i + 1}>
                          {new Date(2000, i, 1).toLocaleDateString('en', { month: 'short' })}
                        </Option>
                      ))}
                    </Select>
                  </>
                )}
                <Button
                  icon={<ReloadOutlined />}
                  onClick={fetchRevenueData}
                  loading={revenueLoading}
                />
              </Space>
            }
          >
            <div style={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={getRevenueData()}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey={getRevenueXAxisKey()} />
                  <YAxis />
                  <Tooltip 
                    formatter={(value: any) => [`$${value}`, 'Revenue']}
                  />
                  <Legend />
                  <Line 
                    name="Platform Revenue"
                    type="monotone" 
                    dataKey="revenue" 
                    stroke="#1890ff" 
                    strokeWidth={2}
                    activeDot={{ r: 6 }} 
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col xs={24}>
          <Card title={t('admin.recentOrders')} bordered={false}>
            <Table
              columns={columns}
              dataSource={stats.recentOrders || []}
              rowKey="id"
              pagination={false}
              size="small"
            />
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default AdminStatistics;
