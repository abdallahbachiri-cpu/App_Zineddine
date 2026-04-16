import React, { useState, useEffect } from "react";
import {
  Table,
  Card,
  Input,
  Row,
  Col,
  Typography,
  Pagination,
  Rate,
  Space,
  Tabs,
  message,
  Button,
  Select,
} from "antd";
import { useTranslation } from "react-i18next";
import api from '../../services/httpClient';
import debounce from "lodash/debounce";

const { TabPane } = Tabs;
const { Title, Text } = Typography;
const { Search } = Input;

type FoodStore = {
  id: string;
  name: string;
  // other properties from your DTO
};

type Dish = {
  id: string;
  name: string;
  // other properties from your DTO
};

type Rating = {
  id: string;
  rating: number;
  comment: string;
  createdAt: string;
  buyerName: string;
  dishName?: string;
  orderId: string;
};



const AdminRatings: React.FC = () => {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = useState<"food-store" | "dish">("food-store");
  const [selectedId, setSelectedId] = useState<string>("");
  const [selectedName, setSelectedName] = useState<string>("");
  const [foodStores, setFoodStores] = useState<FoodStore[]>([]);
  const [dishes, setDishes] = useState<Dish[]>([]);
  const [ratings, setRatings] = useState<Rating[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadingOptions, setLoadingOptions] = useState(false);
  const [total, setTotal] = useState(0);
  const [searchQuery, setSearchQuery] = useState("");
  const [optionsPage, setOptionsPage] = useState(1);
  const [optionsTotal, setOptionsTotal] = useState(0);
  const [filters, setFilters] = useState({
    page: 1,
    limit: 10,
    sortBy: "createdAt",
    sortOrder: "desc",
    search: "",
    minRating: null as number | null,
    maxRating: null as number | null,
    buyerId: "",
    orderId: "",
  });

  // Debounced search for food stores
  const searchFoodStores = debounce(async (query: string, page: number = 1) => {
    setLoadingOptions(true);
    try {
      const response = await api.get("/admin/food-stores", {
        params: {
          search: query,
          limit: 10,
          page: page,
          sortBy: "name",
          sortOrder: "asc",
        },
      });
      setFoodStores(response.data.data);
      setOptionsTotal(response.data.total);
    } catch (error) {
      message.error(t("ratings.fetchStoresError"));
    } finally {
      setLoadingOptions(false);
    }
  }, 500);

  // Debounced search for dishes
  const searchDishes = debounce(async (query: string, page: number = 1) => {
    setLoadingOptions(true);
    try {
      const response = await api.get("/admin/dishes", {
        params: {
          search: query,
          limit: 10,
          page: page,
          sortBy: "name",
          sortOrder: "asc",
        },
      });
      setDishes(response.data.data);
      setOptionsTotal(response.data.total);
    } catch (error) {
      message.error(t("ratings.fetchDishesError"));
    } finally {
      setLoadingOptions(false);
    }
  }, 500);

  useEffect(() => {
    if (activeTab === "food-store") {
      searchFoodStores(searchQuery, optionsPage);
    } else {
      searchDishes(searchQuery, optionsPage);
    }
  }, [activeTab, searchQuery, optionsPage]);

  useEffect(() => {
    if (selectedId) {
      fetchRatings();
    }
  }, [filters, selectedId, activeTab]);

  const fetchRatings = async () => {
    setLoading(true);
    try {
      const endpoint =
        activeTab === "food-store"
          ? `/admin/food-store/${selectedId}/ratings`
          : `/admin/dishes/${selectedId}/ratings`;

      const response = await api.get(endpoint, {
        params: {
          page: filters.page,
          limit: filters.limit,
          sortBy: filters.sortBy,
          sortOrder: filters.sortOrder,
          search: filters.search || undefined,
          minRating: filters.minRating || undefined,
          maxRating: filters.maxRating || undefined,
          buyerId: filters.buyerId || undefined,
          orderId: filters.orderId || undefined,
        },
      });

      setRatings(response.data.data);
      setTotal(response.data.total);
    } catch (error) {
      message.error(t("ratings.fetchRatingsError"));
    } finally {
      setLoading(false);
    }
  };

  const handleSelection = (id: string, name: string) => {
    setSelectedId(id);
    setSelectedName(name);
  };

  const columns = [
    {
      title: t("ratings.buyer"),
      dataIndex: "buyerName",
      key: "buyerName",
    },
    {
      title: t("ratings.rating"),
      dataIndex: "rating",
      key: "rating",
      render: (rating: number) => <Rate disabled defaultValue={rating} />,
    },
    {
      title: t("ratings.comment"),
      dataIndex: "comment",
      key: "comment",
    },
    {
      title: t("ratings.orderId"),
      dataIndex: "orderId",
      key: "orderId",
      render: (id: string) => <Text copyable>{id}</Text>,
    },
    {
      title: t("ratings.date"),
      dataIndex: "createdAt",
      key: "createdAt",
      render: (date: string) => new Date(date).toLocaleDateString(),
    },
  ];

  if (activeTab === "dish") {
    columns.splice(1, 0, {
      title: t("ratings.dish"),
      dataIndex: "dishName",
      key: "dishName",
    });
  }

  const optionsColumns = [
    {
      title: t(activeTab === "food-store" ? "ratings.storeName" : "ratings.dishName"),
      dataIndex: "name",
      key: "name",
    },
    {
      title: t("ratings.action"),
      key: "action",
      render: (_: any, record: FoodStore | Dish) => (
        <Button
          type="primary"
          onClick={() => handleSelection(record.id, record.name)}
          disabled={selectedId === record.id}
        >
          {selectedId === record.id ? t("ratings.selected") : t("ratings.select")}
        </Button>
      ),
    },
  ];

  return (
    <Card>
      <Title level={4}>{t("ratings.title")}</Title>

      <Tabs
        activeKey={activeTab}
        onChange={(key) => {
          setActiveTab(key as "food-store" | "dish");
          setSelectedId("");
          setSelectedName("");
          setRatings([]);
          setSearchQuery("");
          setOptionsPage(1);
        }}
      >
        <TabPane tab={t("ratings.foodStoreTab")} key="food-store">
          <div style={{ marginBottom: 16 }}>
            <Search
              placeholder={t("ratings.searchStorePlaceholder")}
              allowClear
              enterButton
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{ marginBottom: 16 }}
            />
            <Table
              columns={optionsColumns}
              dataSource={foodStores}
              rowKey="id"
              loading={loadingOptions}
              pagination={{
                current: optionsPage,
                pageSize: 10,
                total: optionsTotal,
                onChange: (page) => setOptionsPage(page),
              }}
            />
          </div>
        </TabPane>
        <TabPane tab={t("ratings.dishTab")} key="dish">
          <div style={{ marginBottom: 16 }}>
            <Search
              placeholder={t("ratings.searchDishPlaceholder")}
              allowClear
              enterButton
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{ marginBottom: 16 }}
            />
            <Table
              columns={optionsColumns}
              dataSource={dishes}
              rowKey="id"
              loading={loadingOptions}
              pagination={{
                current: optionsPage,
                pageSize: 10,
                total: optionsTotal,
                onChange: (page) => setOptionsPage(page),
              }}
            />
          </div>
        </TabPane>
      </Tabs>

      {selectedId && (
        <>
          <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
            <Col xs={24}>
              <Text strong>
                {t(activeTab === "food-store" ? "ratings.viewingStore" : "ratings.viewingDish")}:{" "}
                {selectedName}
              </Text>
            </Col>
            <Col xs={24} sm={12} md={8}>
              <Space>
                <Select
                  placeholder={t("ratings.minRating")}
                  style={{ width: 120 }}
                  allowClear
                  onChange={(value) =>
                    setFilters({ ...filters, minRating: value, page: 1 })
                  }
                >
                  {[1, 2, 3, 4, 5].map((num) => (
                    <Select.Option key={`min-${num}`} value={num}>
                      {num}+
                    </Select.Option>
                  ))}                </Select>

                <Select
                  placeholder={t("ratings.maxRating")}
                  style={{ width: 120 }}
                  allowClear
                  onChange={(value) =>
                    setFilters({ ...filters, maxRating: value, page: 1 })
                  }
                >
                  {[1, 2, 3, 4, 5].map((num) => (
                    <Select.Option key={`max-${num}`} value={num}>
                      {num}-
                    </Select.Option>
                  ))}                </Select>
              </Space>
            </Col>
          </Row>

          <Table
            columns={columns}
            dataSource={ratings}
            rowKey="id"
            loading={loading}
            pagination={false}
          />

          <div style={{ marginTop: 16, textAlign: "right" }}>
            <Pagination
              current={filters.page}
              pageSize={filters.limit}
              total={total}
              onChange={(page, pageSize) =>
                setFilters({ ...filters, page, limit: pageSize })
              }
              showSizeChanger
              showQuickJumper
              showTotal={(total) => t("ratings.totalRatings", { total })}
            />
          </div>
        </>
      )}
    </Card>
  );
};

export default AdminRatings;