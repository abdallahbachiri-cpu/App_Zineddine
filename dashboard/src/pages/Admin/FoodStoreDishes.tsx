import React, { useState, useEffect, useCallback } from "react";
import {
  Card,
  Typography,
  Tag,
  Button,
  Space,
  Table,
  message,
  Spin,
  Breadcrumb,
  Input,
  Select,
  Modal,
  Image,
} from "antd";
import { useParams, useNavigate, Link } from "react-router-dom";
import {
  getFoodStoreById,
  getFoodStoreDishes,
  type FoodStoreData,
  type DishData,
  GalleryImageData
} from "../../services/adminStoreService";
import { useTranslation } from "react-i18next";
import {
  ShopOutlined,
  EyeOutlined,
  SearchOutlined,
  ArrowLeftOutlined,
  HomeOutlined
} from '@ant-design/icons';
import type { ColumnsType } from "antd/es/table";
import API_BASE_URL from "../../config/apiConfig";

const { Title, Text } = Typography;
const { Search } = Input;
const { Option } = Select;

const FoodStoreDishes: React.FC = () => {
  const { t } = useTranslation();
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  
  const [foodStore, setFoodStore] = useState<FoodStoreData | null>(null);
  const [dishes, setDishes] = useState<DishData[]>([]);
  const [filteredDishes, setFilteredDishes] = useState<DishData[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [sortBy, setSortBy] = useState<string>("name");
  const [selectedDish, setSelectedDish] = useState<DishData | null>(null);
  const [detailModalVisible, setDetailModalVisible] = useState(false);

  const fetchFoodStoreAndDishes = useCallback(async () => {
    if (!id) return;
    
    setLoading(true);
    try {
      const [storeDetails, storeDishes] = await Promise.all([
        getFoodStoreById(id),
        getFoodStoreDishes(id)
      ]);
      
      setFoodStore(storeDetails);
      setDishes(storeDishes);
      setFilteredDishes(storeDishes);
    } catch (error) {
      console.error("Failed to fetch food store dishes", error);
      message.error(t("foodStores.messages.error") || "Failed to fetch food store dishes");
    } finally {
      setLoading(false);
    }
  }, [id, t]);

  useEffect(() => {
    fetchFoodStoreAndDishes();
  }, [fetchFoodStoreAndDishes]);

  useEffect(() => {
    let filtered = [...dishes];
    
    // Apply search filter
    if (searchText) {
      filtered = filtered.filter(dish =>
        dish.name.toLowerCase().includes(searchText.toLowerCase()) ||
        (dish.description && dish.description.toLowerCase().includes(searchText.toLowerCase()))
      );
    }
    
    // Apply status filter
    if (statusFilter !== "all") {
      filtered = filtered.filter(dish => 
        statusFilter === "active" ? dish.available : !dish.available
      );
    }
    
    // Apply sorting
    filtered.sort((a, b) => {
      switch (sortBy) {
        case "name":
          return a.name.localeCompare(b.name);
        case "price":
          return a.price - b.price;
        case "createdAt":
          return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        case "updatedAt":
          return new Date(a.updatedAt).getTime() - new Date(b.updatedAt).getTime();
        default:
          return 0;
      }
    });
    
    setFilteredDishes(filtered);
  }, [dishes, searchText, statusFilter, sortBy]);

  const handleViewDishDetail = (dish: DishData) => {
    setSelectedDish(dish);
    setDetailModalVisible(true);
  };
  
  const dishColumns: ColumnsType<DishData> = [
    {
      title: t("foodStores.dishes.image"),
      dataIndex: "gallery",
      key: "gallery",
      width: 80,
      render: (gallery: Array<GalleryImageData> | undefined, record: DishData) => (
        <Image
          src={gallery && gallery.length > 0 ? `${API_BASE_URL}${gallery[0]?.url}` : undefined}
          alt={record.name}
          style={{ width: 48, height: 48, objectFit: 'cover', borderRadius: 4 }}
        />
      ),
    },
    {
      title: t("foodStores.dishes.name"),
      dataIndex: "name",
      key: "name",
      render: (text: string) => (
        <Text strong>{text}</Text>
      ),
      sorter: true,
    },
    {
      title: t("foodStores.dishes.description"),
      dataIndex: "description",
      key: "description",
      ellipsis: true,
      width: 300,
    },
    {
      title: t("foodStores.dishes.price"),
      dataIndex: "price",
      key: "price",
      render: (price: number) => `$${price}`,
      sorter: true,
    },
    {
      title: t("foodStores.dishes.status"),
      dataIndex: "available",
      key: "available",
      render: (available: boolean) => (
        <Tag color={available ? "green" : "red"}>
          {available ? 
            (t("foodStores.dishes.active") ) : 
            (t("foodStores.dishes.inactive"))
          }
        </Tag>
      ),
      filters: [
        { text: t("foodStores.dishes.active"), value: true },
        { text: t("foodStores.dishes.inactive"), value: false },
      ],
      onFilter: (value: any, record: DishData) => record.available === value,
    },
    {
      title: t("foodStores.dishes.createdAt"),
      dataIndex: "createdAt",
      key: "createdAt",
      render: (date: string) => new Date(date).toLocaleDateString(),
      sorter: true,
    },
    {
      title: t("common.actions"),
      key: "actions",
      width: 150,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            icon={<EyeOutlined />}
            onClick={() => handleViewDishDetail(record)}
          >
            {t("common.view")}
          </Button>
        </Space>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="p-6 flex justify-center items-center min-h-64">
        <Spin size="large" />
      </div>
    );
  }

  if (!foodStore) {
    return (
      <div className="p-6">
        <Card>
          <Text type="secondary">
            {t("foodStores.notFound")}
          </Text>
        </Card>
      </div>
    );
  }

  return (
    <div className="p-6">
      <Breadcrumb className="mb-4">
        <Breadcrumb.Item>
          <Link to="/admin">
            <HomeOutlined />
          </Link>
        </Breadcrumb.Item>
        <Breadcrumb.Item>
          <Link to="/admin/food-stores">
            {t("foodStores.title")}
          </Link>
        </Breadcrumb.Item>
        <Breadcrumb.Item>
          <Link to={`/admin/food-stores/${id}`}>
            {foodStore.name}
          </Link>
        </Breadcrumb.Item>
        <Breadcrumb.Item>
          {t("foodStores.dishes.title")}
        </Breadcrumb.Item>
      </Breadcrumb>

      <Card bordered={false}>
        <div className="mb-6">
          <div className="flex justify-between items-center mb-4">
            <Title level={2} style={{ margin: 0 }}>
              {t("foodStores.dishes.title")} - {foodStore.name}
            </Title>
            <Space>
              <Button
                icon={<ArrowLeftOutlined />}
                onClick={() => navigate(`/admin-food-stores/${id}`)}
              >
                {t("common.back")}
              </Button>
            </Space>
          </div>

          <div className="flex gap-4 mb-4">
            <Search
              placeholder={t("foodStores.dishes.searchPlaceholder")}
              allowClear
              enterButton={<SearchOutlined />}
              value={searchText}
              onChange={(e) => setSearchText(e.target.value)}
              style={{ width: 300 }}
            />
            
            <Select
              value={statusFilter}
              onChange={setStatusFilter}
              style={{ width: 150 }}
              placeholder={t("foodStores.dishes.filterByStatus")}
            >
              <Option value="all">{t("foodStores.dishes.allStatus")}</Option>
              <Option value="active">{t("foodStores.dishes.active")}</Option>
              <Option value="inactive">{t("foodStores.dishes.inactive")}</Option>
            </Select>
            
            <Select
              value={sortBy}
              onChange={setSortBy}
              style={{ width: 150 }}
              placeholder={t("foodStores.dishes.sortBy")}
            >
              <Option value="name">{t("foodStores.dishes.sortByName")}</Option>
              <Option value="price">{t("foodStores.dishes.sortByPrice")}</Option>
              <Option value="createdAt">{t("foodStores.dishes.sortByCreatedAt")}</Option>
              <Option value="updatedAt">{t("foodStores.dishes.sortByUpdatedAt")}</Option>
            </Select>
          </div>

          <div className="mb-4">
            <Space>
              <Text type="secondary">
                {t("foodStores.dishes.totalCount")}: {filteredDishes.length} {t("foodStores.dishes.dishes")}
              </Text>
              {statusFilter !== "all" && (
                <Tag color="blue">
                  {t("foodStores.dishes.filtered")}: {statusFilter}
                </Tag>
              )}
            </Space>
          </div>
        </div>

        <Table
          columns={dishColumns}
          dataSource={filteredDishes}
          rowKey="id"
          loading={loading}
          pagination={{
            showSizeChanger: true,
            pageSizeOptions: ['10', '20', '50', '100'],
            showTotal: (total, range) => 
              t("foodStores.dishes.pagination", { 
                start: range[0], 
                end: range[1], 
                total 
              }) || `${range[0]}-${range[1]} of ${total} dishes`,
          }}
          scroll={{ x: 1200 }}
        />
      </Card>

      {/* Dish Detail Modal */}
      <Modal
        title={selectedDish?.name}
        open={detailModalVisible}
        onCancel={() => setDetailModalVisible(false)}
        width={600}
      >
        {selectedDish && (
          <div>
            <div className="mb-4">
              {selectedDish.gallery && selectedDish.gallery.length > 0 && selectedDish.gallery[0]?.url ? (
                
                <Image
                  width="100%"
                  src={`${API_BASE_URL}${selectedDish.gallery[0]?.url}`}
                  alt={selectedDish.name}
                  style={{ borderRadius: 8 }}
                />
              ) : (
                <div className="text-center py-8 bg-gray-100 rounded">
                  <ShopOutlined style={{ fontSize: 48, color: '#ccc' }} />
                  <div className="mt-2">
                    <Text type="secondary">{t("foodStores.dishes.noImage")}</Text>
                  </div>
                </div>
              )}
            </div>
            
            <div className="space-y-2">
              <div>
                <Text strong>{t("foodStores.dishes.name")}:</Text>
                <div>{selectedDish.name}</div>
              </div>
              
              <div>
                <Text strong>{t("foodStores.dishes.description")}:</Text>
                <div>{selectedDish.description || t("foodStores.dishes.noDescription")}</div>
              </div>
              
              <div>
                <Text strong>{t("foodStores.dishes.price")}:</Text>
                <div>${selectedDish.price}</div>
              </div>
              
              <div>
                <Text strong>{t("foodStores.dishes.status")}:</Text>
                <div>
                  <Tag color={selectedDish.available ? "green" : "red"}>
                    {selectedDish.available ? 
                      (t("foodStores.dishes.active")) : 
                      (t("foodStores.dishes.inactive"))
                    }
                  </Tag>
                </div>
              </div>
              
              <div>
                <Text strong>{t("foodStores.dishes.createdAt")}:</Text>
                <div>{new Date(selectedDish.createdAt).toLocaleDateString()}</div>
              </div>
              
              <div>
                <Text strong>{t("foodStores.dishes.updatedAt")}:</Text>
                <div>{new Date(selectedDish.updatedAt).toLocaleDateString()}</div>
              </div>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default FoodStoreDishes;