import React, { useState, useEffect } from "react";
import {
  Table,
  Card,
  Select,
  Input,
  Button,
  Row,
  Col,
  Typography,
  Space,
} from "antd";
import type { ColumnsType } from "antd/es/table";
import {
  FilterOutlined,
  ReloadOutlined,
} from "@ant-design/icons";
import dayjs from "dayjs";
import customParseFormat from "dayjs/plugin/customParseFormat";
import API from '../../services/httpClient';
import { useTranslation } from "react-i18next";

dayjs.extend(customParseFormat);

const { Title } = Typography;
const { Option } = Select;

interface Rating {
  id: string;
  rating: number;
  comment: string;
  createdAt: string;
  buyerName: string;
  buyerId: string;
  orderNumber: string;
  orderId: string;
  dishId?: string;
  dishName?: string;
}

interface Pagination {
  current: number;
  pageSize: number;
  total?: number;
}

const SellerRating: React.FC = () => {
  const { t } = useTranslation();
  const [ratings, setRatings] = useState<Rating[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [pagination, setPagination] = useState<Pagination>({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [filters, setFilters] = useState({
    search: "",
    minRating: undefined as number | undefined,
    maxRating: undefined as number | undefined,
    dishId: undefined as string | undefined,
    buyerId: undefined as string | undefined,
    orderId: undefined as string | undefined,
    dateRange: undefined as [string, string] | undefined,
  });
  const [orderNumberSearch, setOrderNumberSearch] = useState<string>("");
  const [buyerNameSearch, setBuyerNameSearch] = useState<string>("");
  const [dishes, setDishes] = useState<{ id: string; name: string }[]>([]);
  const [foodStoreName, setFoodStoreName] = useState<string>("");

  const fetchRatings = async () => {
    setLoading(true);
    try {
      const queryParams = new URLSearchParams();
      queryParams.append("page", pagination.current.toString());
      queryParams.append("limit", pagination.pageSize.toString());

      if (filters.search) queryParams.append("search", filters.search);
      if (filters.minRating)
        queryParams.append("minRating", filters.minRating.toString());
      if (filters.maxRating)
        queryParams.append("maxRating", filters.maxRating.toString());
      if (filters.dishId) queryParams.append("dishId", filters.dishId);
      if (filters.buyerId) queryParams.append("buyerId", filters.buyerId);
      if (filters.orderId) queryParams.append("orderId", filters.orderId);
      if (filters.dateRange) {
        queryParams.append("startDate", filters.dateRange[0]);
        queryParams.append("endDate", filters.dateRange[1]);
      }

      let url = "/seller/food-store/ratings";
      if (filters.dishId) {
        url = `/seller/food-store/dishes/${filters.dishId}/ratings`;
      }

      const response = await API.get(`${url}?${queryParams.toString()}`);
      const data = await response.data.data;

      setRatings(data.items || data);
      setPagination({
        ...pagination,
        total: data.total || 0,
      });
    } catch (error) {
      console.error("Error fetching ratings:", error);
    } finally {
      setLoading(false);
    }
  };

  const fetchStoreInfo = async () => {
    try {
      const response = await API.get("/seller/food-store");
      const data = await response.data;

      setFoodStoreName(data.name);
    } catch (error) {
      console.error("Error fetching store info:", error);
    }
  };

  const fetchDishes = async () => {
    try {
      const response = await API.get("/seller/food-store/dishes");
      const data = await response.data;
      setDishes(data);
    } catch (error) {
      console.error("Error fetching dishes:", error);
    }
  };

  useEffect(() => {
    fetchStoreInfo();
    fetchDishes();
  }, []);

  useEffect(() => {
    fetchRatings();
  }, [pagination.current, pagination.pageSize, filters]);

  const handleTableChange = (newPagination: any) => {
    setPagination({
      current: newPagination.current || 1,
      pageSize: newPagination.pageSize || 10,
      total: pagination.total,
    });
  };

  const handleSearch = () => {
    // Find the orderId based on the orderNumber input
    const ratingWithOrderNumber = ratings.find(
      (rating) => rating.orderNumber === orderNumberSearch
    );
    
    // Find the buyerId based on the buyerName input
    const ratingWithBuyerName = ratings.find(
      (rating) => rating.buyerName === buyerNameSearch
    );

    setFilters({
      ...filters,
      orderId: ratingWithOrderNumber?.orderId || undefined,
      buyerId: ratingWithBuyerName?.buyerId || undefined,
    });
    setPagination({ ...pagination, current: 1 });
  };

  const resetFilters = () => {
    setFilters({
      search: "",
      minRating: undefined,
      maxRating: undefined,
      dishId: undefined,
      buyerId: undefined,
      orderId: undefined,
      dateRange: undefined,
    });
    setOrderNumberSearch("");
    setBuyerNameSearch("");
    setPagination({ ...pagination, current: 1 });
  };

  const columns: ColumnsType<Rating> = [
    {
      title: t('rating.seller.table.columns.rating'),
      dataIndex: "rating",
      key: "rating",
      width: 100,
      sorter: true,
      render: (rating: number) => (
        <span
          style={{
            fontWeight: "bold",
            color:
              rating >= 4 ? "#52c41a" : rating >= 3 ? "#faad14" : "#f5222d",
          }}
        >
          {rating} ★
        </span>
      ),
    },
    {
      title: t('rating.seller.table.columns.comment'),
      dataIndex: "comment",
      key: "comment",
      ellipsis: true,
    },
    {
      title: t('rating.seller.table.columns.buyer'),
      dataIndex: ["buyer", "name"],
      key: "buyer",
      render: (_, record) => {
        return (
            <div>{record.buyerName}</div>
        );
      },
    },
    {
      title: t('rating.seller.table.columns.dish'),
      dataIndex: ["dish", "name"],
      key: "dish",
      render: (_dishName, record) => {
        return record ? (
          <div>{record.dishName}</div>
        ) : (
          t('rating.notAvailable')
        );
      },
    },
    {
      title: t('rating.seller.table.columns.order'),
      dataIndex: ["order", "orderNumber"],
      key: "order",
      render: (_, record) => (
          <div>#{record.orderNumber}</div>
      ),
    },
    {
      title: t('rating.seller.table.columns.date'),
      dataIndex: "createdAt",
      key: "createdAt",
      render: (date: string) => dayjs(date).format("YYYY-MM-DD HH:mm"),
      sorter: true,
    },
  ];

  return (
    <div className="seller-ratings-container p-8">
      <Title level={2}>{t('rating.seller.title', { foodStoreName })}</Title>
      <Card>
        <Row gutter={[16, 16]} style={{ marginBottom: 20 }}>
          <Col xs={24} sm={12} md={6}>
            <Select
              style={{ width: "100%" }}
              placeholder={t('rating.seller.filters.dish')}
              allowClear
              value={filters.dishId}
              onChange={(value) => setFilters({ ...filters, dishId: value })}
            >
              {dishes.map((dish) => (
                <Option key={dish.id} value={dish.id}>
                  {dish.name}
                </Option>
              ))}
            </Select>
          </Col>

          <Col xs={24} sm={12} md={4}>
            <Select
              style={{ width: "100%" }}
              placeholder={t('rating.seller.filters.minRating')}
              allowClear
              value={filters.minRating}
              onChange={(value) => setFilters({ ...filters, minRating: value })}
            >
              {[1, 2, 3, 4, 5].map((num) => (
                <Option key={num} value={num}>
                  {t(`rating.stars.${num}`)}
                </Option>
              ))}
            </Select>
          </Col>

          <Col xs={24} sm={12} md={4}>
            <Select
              style={{ width: "100%" }}
              placeholder={t('rating.seller.filters.maxRating')}
              allowClear
              value={filters.maxRating}
              onChange={(value) => setFilters({ ...filters, maxRating: value })}
            >
              {[1, 2, 3, 4, 5].map((num) => (
                <Option key={num} value={num}>
                  {t(`rating.stars.${num}`)}
                </Option>
              ))}
            </Select>
          </Col>

          <Col xs={24} sm={12} md={4}>
            <Input
              placeholder={t('rating.seller.filters.buyerName')}
              value={buyerNameSearch}
              onChange={(e) => setBuyerNameSearch(e.target.value)}
              allowClear
            />
          </Col>

          <Col xs={24} sm={12} md={4}>
            <Input
              placeholder={t('rating.seller.filters.orderNumber')}
              value={orderNumberSearch}
              onChange={(e) => setOrderNumberSearch(e.target.value)}
              allowClear
            />
          </Col>

          <Col xs={24} sm={12} md={4}>
            <Space>
              <Button
                type="primary"
                icon={<FilterOutlined />}
                onClick={handleSearch}
              >
                {t('rating.seller.actions.filter')}
              </Button>
              <Button icon={<ReloadOutlined />} onClick={resetFilters}>
                {t('rating.seller.actions.reset')}
              </Button>
            </Space>
          </Col>
        </Row>

        <Table
          columns={columns}
          rowKey="id"
          dataSource={ratings}
          loading={loading}
          pagination={{
            current: pagination.current,
            pageSize: pagination.pageSize,
            total: pagination.total,
            showSizeChanger: true,
            pageSizeOptions: ["10", "20", "50", "100"],
            showTotal: (total, range) =>
              t('rating.pagination.showing', {
                range0: range[0],
                range1: range[1],
                total
              }),
          }}
          onChange={handleTableChange}
          scroll={{ x: true }}
        />
      </Card>
    </div>
  );
};

export default SellerRating;