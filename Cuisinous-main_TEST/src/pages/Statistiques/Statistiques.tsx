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
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from "recharts";
import {
  DollarOutlined,
  ShoppingOutlined,
  StarOutlined,
  ClockCircleOutlined,
  UserOutlined,
  CheckCircleOutlined,
  ReloadOutlined
} from "@ant-design/icons";
import API from "../../services/api";
import { getBasicStats, getRevenueByYear, getRevenueByMonth, getRevenueByDay } from "../../services/statisticService";
import { useTranslation } from "react-i18next";

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

interface Dish {
  id: string;
  name: string;
  orderCount: number;
  averageRating: number;
}

type OrderStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled';

const SellerStatistics = () => {
  const { t } = useTranslation();
  const [loading, setLoading] = useState(true);
  const [revenueLoading, setRevenueLoading] = useState(false);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [revenueView, setRevenueView] = useState<'year' | 'month' | 'day'>('month');
  const [stats, setStats] = useState({
    totalRevenue: 0,
    totalOrders: 0,
    completedOrders: 0,
    averageRating: 0,
    recentOrders: [] as Order[],
    popularDishes: [] as Dish[],
    monthlyRevenue: [] as { date: string; revenue: number }[],
    yearlyRevenue: [] as { year: string; revenue: number }[],
    monthlyRevenueByYear: [] as { month: string; revenue: number }[],
    dailyRevenueByMonth: [] as { day: string; revenue: number }[]
  });

const fetchRevenueData = async () => {
  try {
    setRevenueLoading(true);
    
    if (revenueView === 'year') {
        const response = await getRevenueByYear();
        // Access the specific key from backend: revenueByYear
        const dataObj = response?.revenueByYear || response || {}; 
        const yearlyData = Object.keys(dataObj).map(year => ({
          year: year,
          revenue: parseFloat(dataObj[year]) || 0
        }));
        
      setStats(prev => ({ ...prev, yearlyRevenue: yearlyData }));

    } else if (revenueView === 'month') {
        const response = await getRevenueByMonth(selectedYear);
        // Access the specific key from backend: revenueByMonth
        const dataObj = response?.revenueByMonth || response || {};
        const monthlyData = Object.keys(dataObj).map(month => ({
          month: month, // Keep as "1", "2" etc.
          revenue: parseFloat(dataObj[month]) || 0
        }));

      setStats(prev => ({ ...prev, monthlyRevenueByYear: monthlyData }));

    } else if (revenueView === 'day') {
      const response = await getRevenueByDay(selectedYear, selectedMonth);
      // Handles the specific structure you showed earlier
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
        
        const basicStats = await getBasicStats();
        
        const [
          ordersRes, 
          dishesRes, 
          walletRes
        ] = await Promise.all([
          API.get('/seller/food-store/orders'),
          API.get('/seller/food-store/dishes'),
          API.get('/seller/food-store/wallet')
        ]);

        const orders = ordersRes.data.data || [];
        const dishes = dishesRes.data || [];
        const wallet = walletRes.data;

        const totalRevenue = basicStats?.totalRevenue || wallet?.balance || 0;
        const totalOrders = basicStats?.totalOrders || orders.length;
        const completedOrders = orders.filter((o: { status: string; }) => o.status === 'completed').length;
        const averageRating = dishes.reduce((sum: number, dish: Dish) => sum + dish.averageRating, 0) / dishes.length || 0;

        const recentOrders = orders
          .sort((a: Order, b: Order) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
          .slice(0, 5);

        const popularDishes = dishes
          .sort((a: Dish, b: Dish) => b.orderCount - a.orderCount)
          .slice(0, 5);

        const monthlyRevenue = Array.from({ length: 30 }, (_, i) => ({
          date: new Date(Date.now() - (29 - i) * 24 * 60 * 60 * 1000).toLocaleDateString(),
          revenue: Math.round(Math.random() * 1000 + 500)
        }));

        setStats(prev => ({
          ...prev,
          totalRevenue,
          totalOrders,
          completedOrders,
          averageRating: isNaN(averageRating) ? 0 : averageRating,
          recentOrders,
          popularDishes,
          monthlyRevenue
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
      title: t('sellerStats.recentOrders.columns.orderNumber'),
      dataIndex: 'orderNumber',
      key: 'orderNumber',
      render: (text: string) => <Text copyable>{text}</Text>
    },
    {
      title: t('sellerStats.recentOrders.columns.amount'),
      dataIndex: 'totalPrice',
      key: 'totalPrice',
      render: (totalPrice: number) => `${totalPrice}`
    },
    {
      title: t('sellerStats.recentOrders.columns.status'),
      dataIndex: 'status',
      key: 'status',
      render: (status: OrderStatus) => {
        const statusMap = {
          pending: { color: 'gold', text: t('sellerStats.recentOrders.status.pending') },
          confirmed: { color: 'blue', text: t('sellerStats.recentOrders.status.confirmed') },
          completed: { color: 'green', text: t('sellerStats.recentOrders.status.completed') },
          cancelled: { color: 'red', text: t('sellerStats.recentOrders.status.cancelled') }
        };
        return <Tag color={statusMap[status].color}>{statusMap[status].text}</Tag>;
      }
    },
    {
      title: t('sellerStats.recentOrders.columns.date'),
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
        return stats.monthlyRevenue;
    }
  };

  const getRevenueChartTitle = () => {
    switch (revenueView) {
      case 'year':
        return 'Revenue by Year';
      case 'month':
        return `Revenue by Month - ${selectedYear}`;
      case 'day':
        return `Revenue by Day - ${selectedMonth}/${selectedYear}`;
      default:
        return t('sellerStats.charts.monthlyRevenue');
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
        <Spin size="large" tip={t('sellerStats.loading')} />
      </div>
    );
  }

  return (
    <div style={{ padding: 24 }}>
      <Title level={3} style={{ marginBottom: 24 }}>{t('sellerStats.title')}</Title>
      
      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Statistic
              title={t('sellerStats.cards.totalRevenue')}
              value={stats.totalRevenue}
              precision={2}
              prefix={<DollarOutlined />}
              valueStyle={{ color: '#3f8600' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Statistic
              title={t('sellerStats.cards.totalOrders')}
              value={stats.totalOrders}
              prefix={<ShoppingOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Statistic
              title={t('sellerStats.cards.completionRate')}
              value={(stats.completedOrders / stats.totalOrders * 100).toFixed(1)}
              suffix="%"
              prefix={<CheckCircleOutlined />}
            />
            <Progress 
              percent={Math.round(stats.completedOrders / stats.totalOrders * 100)} 
              size="small" 
              status="active" 
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card bordered={false}>
            <Statistic
              title={t('sellerStats.cards.averageRating')}
              value={stats.averageRating}
              precision={1}
              prefix={<StarOutlined />}
              suffix="/5"
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
                  <Option value="year">Yearly</Option>
                  <Option value="month">Monthly</Option>
                  <Option value="day">Daily</Option>
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
                    name="Revenue"
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
        <Col xs={24} lg={12}>
          <Card 
            title={t('sellerStats.charts.popularDishes')} 
            extra={<Tag icon={<UserOutlined />} color="blue">{t('sellerStats.charts.byOrders')}</Tag>}
          >
            <div style={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={stats.popularDishes}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar 
                    name={t('sellerStats.charts.orders')}
                    dataKey="orderCount" 
                    fill="#8884d8" 
                    radius={[4, 4, 0, 0]} 
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </Card>
        </Col>
      </Row>

      <Card 
        title={t('sellerStats.recentOrders.title')} 
        extra={<Tag icon={<ClockCircleOutlined />} color="blue">{t('sellerStats.recentOrders.latest5')}</Tag>}
      >
        <Table
          columns={columns}
          dataSource={stats.recentOrders}
          rowKey="id"
          pagination={false}
          size="middle"
        />
      </Card>
    </div>
  );
};

export default SellerStatistics;
