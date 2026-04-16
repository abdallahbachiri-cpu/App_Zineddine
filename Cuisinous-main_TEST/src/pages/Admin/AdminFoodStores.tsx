import React, { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import {
  Table,
  Tag,
  message,
  Typography,
  Button,
  Space,
  Card,
  Avatar,
  Modal,
  Descriptions,
  Image
} from "antd";
import type { ColumnsType } from "antd/es/table";
import {
  getFoodStores,
  type FoodStoreData,
  type DishData,
  type FoodStoreSearchParams
} from "../../services/adminFoodStoreService";
import SearchBar from "../../components/SearchBar";
import { useTranslation } from "react-i18next";
import {
  ShopOutlined,
  EyeOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  CalendarOutlined
} from '@ant-design/icons';
import API_BASE_URL from "../../config/apiConfig";
const { Title, Text } = Typography;
const AdminFoodStores: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [foodStores, setFoodStores] = useState<FoodStoreData[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    totalItems: 0,
    totalPages: 0,
    currentPage: 1,
    limit: 10,
  });
  const [searchParams, setSearchParams] = useState<FoodStoreSearchParams>({
    search: "",
    page: 1,
    limit: 10,
    sortBy: "createdAt",
    sortOrder: "DESC",
  });
  const [detailsModalVisible, setDetailsModalVisible] = useState(false);
  const [selectedFoodStore ] = useState<FoodStoreData | null>(null);
  const [storeDishes] = useState<DishData[]>([]);
  const [dishesLoading] = useState(false);

  const fetchFoodStores = useCallback(async () => {
    setLoading(true);
    try {
      const response = await getFoodStores(searchParams);
      
      setFoodStores(response.data);
      setPagination(prev => ({
        ...prev,
        totalItems: response.total_items,
        totalPages: response.total_pages,
        currentPage: response.current_page,
        limit: response.limit,
      }));
      
    } catch (error) {
      console.error("Failed to fetch food stores", error);
      message.error(t("foodStores.messages.error") || "Failed to fetch food stores");
    } finally {
      setLoading(false);
    }
  }, [searchParams, t]);

  useEffect(() => {
    fetchFoodStores();
  }, [fetchFoodStores]);

  const handleSearchChange = (value: string) => {
    setSearchParams((prev) => ({
      ...prev,
      search: value,
      page: 1,
    }));
  };

  const handleStatusFilter = (value: string) => {
    setSearchParams((prev) => ({
      ...prev,
      isActive: value === "active" ? true : value === "inactive" ? false : undefined,
      page: 1,
    }));
  };


  const handleSortChange = (value: string) => {
    setSearchParams((prev) => ({
      ...prev,
      sortBy: value,
      sortOrder:
        prev.sortBy === value
          ? prev.sortOrder === "ASC"
            ? "DESC"
            : "ASC"
          : "ASC",
    }));
  };


  const columns: ColumnsType<FoodStoreData> = [
    {
      title: t("foodStores.table.columns.store") || "Food Store",
      key: "store",
      render: (_, record) => (
        <Space>
          <Avatar
            src={record.profileImageUrl}
            icon={<ShopOutlined />}
            style={{ backgroundColor: '#1890ff' }}
          />
          <div>
            <div style={{ fontWeight: 'bold' }}>{record.name}</div>
            {record.description && (
              <Text type="secondary" style={{ fontSize: 12 }}>
                {record.description}
              </Text>
            )}
          </div>
        </Space>
      ),
      sorter: true,
    },
    {
      title: t("foodStores.table.columns.vendorAgreement"),
      key: "vendorAgreement",
      render: (_, record) => (
        <Space direction="vertical" size={0}>
          <Space>
            {record.vendorAgreementAccepted ? (
              <>
                <CheckCircleOutlined style={{ color: '#52c41a' }} />
                <Tag color="green">{t("foodStores.vendorAgreement.accepted")}</Tag>
              </>
            ) : (
              <>
                <CloseCircleOutlined style={{ color: '#ff4d4f' }} />
                <Tag color="red">{t("foodStores.vendorAgreement.notAccepted")}</Tag>
              </>
            )}
          </Space>
          {record.vendorAgreementAcceptedAt && (
            <Text type="secondary" style={{ fontSize: 12 }}>
              <CalendarOutlined /> {new Date(record.vendorAgreementAcceptedAt).toLocaleDateString()}
            </Text>
          )}
        </Space>
      ),
    },
    // this column is commented because the verification request process was removed 
    // {
    //   title: t("foodStores.table.columns.status"),
    //   key: "status",
    //   render: (_, record) => (
    //     <Space direction="vertical" size={0}>
    //       <Space>
    //         {/* {record.isActive ? (
    //           <Tag color="green" icon={<PlayCircleOutlined />}>
    //             {t("foodStores.status.active")}
    //           </Tag>
    //         ) : (
    //           <Tag color="orange" icon={<StopOutlined />}>
    //             {t("foodStores.status.inactive")}
    //           </Tag>
    //         )} */}
    //       </Space>
    //     </Space>
    //   ),
    // },
    {
      title: t("foodStores.table.columns.actions"),
      key: "actions",
      render: (_, record) => (
        <Space size="small">
          <Button
            icon={<EyeOutlined />}
            onClick={() => navigate(`/admin-food-stores/${record.id}`)}
          >
            {t("foodStores.actions.details")}
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <div className="p-6">
      <Card bordered={false}>
        <Title level={2} style={{ marginBottom: 24 }}>
          {t("foodStores.title")}
        </Title>

        <SearchBar
          searchValue={searchParams.search || ""}
          onSearchChange={handleSearchChange}
          placeholder={t("foodStores.search.placeholder")}
          className="mb-6"
          filterOptions={{
            value: searchParams.isActive === true ? "active" : searchParams.isActive === false ? "inactive" : "",
            onChange: handleStatusFilter,
            options: [
              { value: "", label: t("foodStores.search.filter.all")},
              { value: "active", label: t("foodStores.search.filter.active")},
              { value: "inactive", label: t("foodStores.search.filter.inactive")},
            ],
          }}
          sortOptions={{
            value: searchParams.sortBy || "createdAt",
            onChange: handleSortChange,
            options: [
              { value: "name", label: t("foodStores.search.sort.name")}
            ],
          }}
        />
        <Table
          columns={columns}
          dataSource={foodStores}
          rowKey="id"
          loading={loading}
          pagination={{
            current: pagination.currentPage,
            pageSize: pagination.limit,
            total: pagination.totalItems,
            showSizeChanger: true,
            pageSizeOptions: ['10', '20', '50'],
            showTotal: (total, range) => 
              t("foodStores.table.total", { 
                start: range[0], 
                end: range[1], 
                total 
              }) || `${total}`,
          }}
          onChange={(pagination, _filters, sorter) => {
            if (Array.isArray(sorter)) {
              // Handle multiple column sorting if needed
            } else {
              const { field } = sorter;
              if (field) {
                handleSortChange(field as string);
              }
            }
            
            const newPage = pagination.current || 1;
            const newLimit = pagination.pageSize || 10;
            
            setSearchParams(prev => ({
              ...prev,
              page: newPage,
              limit: newLimit
            }));
            
            // Update pagination state immediately for better UX
            setPagination(prev => ({
              ...prev,
              currentPage: newPage,
              limit: newLimit
            }));
          }}
        />
      </Card>

      {/* Food Store Details Modal */}
      <Modal
        title={selectedFoodStore?.name}
        open={detailsModalVisible}
        onCancel={() => setDetailsModalVisible(false)}
        footer={null}
        width={800}
      >
        {selectedFoodStore && (
          <div>
            <Descriptions bordered column={2}>
              <Descriptions.Item label={t("foodStores.details.name")}>
                {selectedFoodStore.name}
              </Descriptions.Item>
              <Descriptions.Item label={t("foodStores.details.status")}>
                <Space>
                  <Tag color={selectedFoodStore.isActive ? "green" : "orange"}>
                    {selectedFoodStore.isActive ? 
                      (t("foodStores.status.active")) : 
                      (t("foodStores.status.inactive"))
                    }
                  </Tag>
                  <Tag color={selectedFoodStore.isVerified ? "blue" : "default"}>
                    {selectedFoodStore.isVerified ? 
                      (t("foodStores.status.verified") ) : 
                      (t("foodStores.status.unverified"))
                    }
                  </Tag>
                </Space>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.description")} span={2}>
                {selectedFoodStore.description || "N/A"}
              </Descriptions.Item>
              <Descriptions.Item label={t("foodStores.details.location")} span={2}>
                <Space direction="vertical">
                  <Text>{selectedFoodStore.address.zipCode}, {selectedFoodStore.address.country}</Text>
                </Space>
              </Descriptions.Item>
              <Descriptions.Item label={t("foodStores.details.vendorAgreement")} span={2}>
                <Space>
                  {selectedFoodStore.vendorAgreementAccepted ? (
                    <Tag color="green">{t("foodStores.vendorAgreement.accepted")}</Tag>
                  ) : (
                    <Tag color="red">{t("foodStores.vendorAgreement.notAccepted")}</Tag>
                  )}
                  {selectedFoodStore.vendorAgreementAcceptedAt && (
                    <Text type="secondary">
                      {new Date(selectedFoodStore.vendorAgreementAcceptedAt).toLocaleDateString()}
                    </Text>
                  )}
                </Space>
              </Descriptions.Item>

              {selectedFoodStore.profileImageUrl && (
                <Descriptions.Item label={t("foodStores.details.profileImage") } span={2}>
                  <Image
                    width={200}
                    src={`${API_BASE_URL}${selectedFoodStore.profileImageUrl}`}
                    alt={selectedFoodStore.name}
                  />
                </Descriptions.Item>
              )}
            </Descriptions>

            {/* Dishes Section */}
            <div style={{ marginTop: 24 }}>
              <Title level={4}>{t("foodStores.details.dishes")}</Title>
              <Table
                dataSource={storeDishes}
                rowKey="id"
                loading={dishesLoading}
                pagination={false}
                size="small"
                columns={[
                  {
                    title: t("foodStores.dishes.name"),
                    dataIndex: "name",
                    key: "name",
                  },
                  {
                    title: t("foodStores.dishes.description"),
                    dataIndex: "description",
                    key: "description",
                    ellipsis: true,
                  },
                  {
                    title: t("foodStores.dishes.price"),
                    dataIndex: "price",
                    key: "price",
                    render: (price: number) => `$${price}`,
                  },
                  {
                    title: t("foodStores.dishes.category"),
                    dataIndex: "category",
                    key: "category",
                  },
                  {
                    title: t("foodStores.dishes.status"),
                    dataIndex: "isActive",
                    key: "isActive",
                    render: (isActive: boolean) => (
                      <Tag color={isActive ? "green" : "red"}>
                        {isActive ? 
                          (t("foodStores.dishes.active")) : 
                          (t("foodStores.dishes.inactive"))
                        }
                      </Tag>
                    ),
                  },
                ]}
              />
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default AdminFoodStores;
