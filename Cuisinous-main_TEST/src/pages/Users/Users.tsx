import React, { useState, useEffect, useCallback } from "react";
import {
  Table,
  Tag,
  message,
  Typography,
  Button,
  Space,
  Card,
  Avatar
} from "antd";
import { useNavigate } from "react-router-dom";
import type { ColumnsType } from "antd/es/table";
import {
  getAllUsers,
  restoreUser,
  activateUser,
  suspendUser,
} from "../../services/userService";
import SearchBar from "../../components/SearchBar";
import { useTranslation } from "react-i18next";
import {
  UserOutlined,
  ShopOutlined,
  CrownOutlined,
  MailOutlined,
  PhoneOutlined,
  EyeOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined
} from '@ant-design/icons';
import api from "../../services/api";
const { Title, Text } = Typography;

interface ClientData {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  isActive: boolean;
  isDeleted: boolean;
  isPhoneConfirmed: boolean;
  type: string;
  foodStore: string;
  foodStoreName?: string; // Add this new property
  avatar?: string;
  createdAt: string;
  lastLogin?: string;
  vendorAgreementAccepted?: boolean;
  vendorAgreementAcceptedAt?: string;
}
const Users: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [users, setUsers] = useState<ClientData[]>([]);
  const [loading, setLoading] = useState(false);
  const [_, setError] = useState<string | null>(null);
  const [pagination, setPagination] = useState({
    totalItems: 0,
    totalPages: 0,
    currentPage: 1,
    limit: 10,
  });
  const [searchParams, setSearchParams] = useState({
    search: "",
    page: 1,
    limit: 10,
    sortBy: "createdAt",
    sortOrder: "DESC",
    type: "",
  });

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      let foodStores: any[] = [];

      const foodStoresResponse = await api.get("/admin/food-stores");
      
      foodStores = foodStoresResponse.data.data;

      // Fetch users data
      const response = await getAllUsers({
        ...searchParams,
        includeFoodStore: true
      });

      const usersData = response.data?.data || response.data;
      
      setPagination(prev => ({
        ...prev,
        totalItems: response.total_items,
        totalPages: response.total_pages,
        currentPage: response.current_page,
        limit: response.limit,
      }));
            
      const mappedUsers = usersData.map((user: any) => {
        let userWithStore = {
          ...user,
          foodStore: user.foodStore || null,
          foodStoreName: null
        };

        const matchingStore = foodStores.find((store: any) => {
          return store.sellerId === user.id
        });

        if (matchingStore) {
          userWithStore.foodStoreName = matchingStore.name;
          userWithStore.vendorAgreementAcceptedAt = matchingStore.vendorAgreementAcceptedAt;
          userWithStore.vendorAgreementAccepted = matchingStore.vendorAgreementAccepted;
        }

        return userWithStore;
      });

      setUsers(mappedUsers);
      
    } catch (error) {
      console.error("Failed to fetch users", error);
      setError(t("users.messages.error"));
    } finally {
      setLoading(false);
    }
  }, [searchParams, t]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const handleSearchChange = (value: string) => {
    setSearchParams((prev) => ({
      ...prev,
      search: value,
      page: 1,
    }));
  };

  const handleTypeFilter = (value: string) => {
    setSearchParams((prev) => ({
      ...prev,
      type: value,
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

  const handleUserAction = async (
    action: () => Promise<void>,
    successKey: string
  ) => {
    try {
      await action();
      message.success(t(successKey));
      setError(null);
      await fetchUsers();
    } catch (error) {
      console.error("Action failed:", error);
      message.error(t("users.messages.error"));
    }
  };

  const getUserTypeIcon = (type: string) => {
    switch (type) {
      case 'seller':
        return <ShopOutlined style={{ color: '#1890ff' }} />;
      case 'admin':
        return <CrownOutlined style={{ color: '#faad14' }} />;
      default:
        return <UserOutlined style={{ color: '#52c41a' }} />;
    }
  };

  const handleViewDetails = (userId: string) => {
    navigate(`/users/${userId}`);
  };
  
  const columns: ColumnsType<ClientData> = [
    {
      title: t("users.table.columns.user"),
      key: "user",
      render: (_, record) => (
        <Space>
          <Avatar
            src={record.avatar}
            icon={<UserOutlined />}
            style={{
              backgroundColor: record.type === 'seller' ? '#1890ff' :
                record.type === 'admin' ? '#faad14' : '#52c41a'
            }}
          />
          <div>
            <div>{`${record.firstName} ${record.lastName}`}</div>
            <Text type="secondary" style={{ fontSize: 12 }}>
              {getUserTypeIcon(record.type)} {
              record.type && t(`users.types.${record.type}`)
              }
            </Text>
          </div>
        </Space>
      ),
      sorter: true,
    },
    {
      title: t("users.table.columns.contact"),
      key: "contact",
      render: (_, record) => (
        <Space direction="vertical" size={0}>
          <a href={`mailto:${record.email}`}>
            <MailOutlined /> {record.email}
          </a>
          {record.phoneNumber && (
            <div>
              <PhoneOutlined /> {record.phoneNumber}
              {record.isPhoneConfirmed && (
                <Tag color="green" style={{ marginLeft: 8 }}>
                  {t("users.table.status.verified")}
                </Tag>
              )}
            </div>
          )}
        </Space>
      ),
    },
    {
      title: t("users.table.columns.foodStore"),
      key: "foodStore",
      render: (_, record) => {
        if (record.type !== 'seller') {
          return <Text type="secondary">-</Text>;
        }

        // Use foodStoreName if available, otherwise fall back to foodStore
        if (record.foodStoreName) {
          return (
            <Space>
              <ShopOutlined />
              {record.foodStoreName}
            </Space>
          );
        }

        if (record.foodStore) {
          return (
            <Space>
              {record.foodStore}
            </Space>
          );
        }

        return (
          <Tag color="default">
            {t("users.table.noFoodStore")}
          </Tag>
        );
      },
    },
    {
      title: t("users.table.columns.vendorAgreement"),
      key: "vendorAgreement",
      render: (_, record) => {
        if (record.type !== 'seller') {
          return <Text type="secondary">-</Text>;
        }
        return (
          <Space direction="vertical" size={0}>
            <Space>
              {record.vendorAgreementAccepted ? (
                <>
                  <CheckCircleOutlined style={{ color: '#52c41a' }} />
                  <Tag color="green">{t("users.vendorAgreement.Accepted")}</Tag>
                </>
              ) : (
                <>
                  <CloseCircleOutlined style={{ color: '#ff4d4f' }} />
                  <Tag color="red">{t("users.vendorAgreement.NotAccepted")}</Tag>
                </>
              )}
            </Space>
            {record.vendorAgreementAcceptedAt && (
              <Text type="secondary" style={{ fontSize: 12 }}>
                {new Date(record.vendorAgreementAcceptedAt).toLocaleDateString()}
              </Text>
            )}
          </Space>
        );
      },
    },
    {
      title: t("users.table.columns.status"),
      key: "status",
      render: (_, record) => (
        <Space>
          {record.isDeleted ? (
            <Tag color="red">{t("users.table.status.deleted")}</Tag>
          ) : record.isActive ? (
            <Tag color="green">{t("users.table.status.active")}</Tag>
          ) : (
            <Tag color="orange">{t("users.table.status.suspended")}</Tag>
          )}
        </Space>
      ),
    },
    {
      title: t("users.table.columns.actions"),
      key: "actions",
      render: (_, record) => (
        <Space size="small">
          <Button
            icon={<EyeOutlined />}
            onClick={() => handleViewDetails(record.id)}
          >
            {t("users.actions.details")}
          </Button>
          {record.isDeleted ? (
            <Button
              onClick={() =>
                handleUserAction(
                  () => restoreUser(record.id),
                  "users.messages.restoreSuccess"
                )
              }
              type="primary"
            >
              {t("users.actions.restore")}
            </Button>
          ) : (
            <>
              {record.isActive ? (
                <Button
                  onClick={() =>
                    handleUserAction(
                      () => suspendUser(record.id),
                      "users.messages.suspendSuccess"
                    )
                  }
                  type="primary"
                  ghost
                >
                  {t("users.actions.suspend")}
                </Button>
              ) : (
                <Button
                  onClick={() =>
                    handleUserAction(
                      () => activateUser(record.id),
                      "users.messages.activateSuccess"
                    )
                  }
                  type="primary"
                >
                  {t("users.actions.activate")}
                </Button>
              )}
            </>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div className="p-6">
      <Card bordered={false}>
        <Title level={2} style={{ marginBottom: 24 }}>
          {t("users.title")}
        </Title>

        <SearchBar
          searchValue={searchParams.search}
          onSearchChange={handleSearchChange}
          placeholder={t("users.search.placeholder")}
          className="mb-6"
          filterOptions={{
            value: searchParams.type,
            onChange: handleTypeFilter,
            options: [
              { value: "", label: t("users.search.filter.all") },
              { value: "buyer", label: t("users.search.filter.buyer") },
              { value: "seller", label: t("users.search.filter.seller") },
              { value: "admin", label: t("users.search.filter.admin") },
            ],
          }}
          sortOptions={{
            value: searchParams.sortBy,
            onChange: handleSortChange,
            options: [
              { value: "firstName", label: t("users.search.sort.firstName") },
              { value: "lastName", label: t("users.search.sort.lastName") },
              { value: "email", label: t("users.search.sort.email") },
              { value: "createdAt", label: t("users.search.sort.createdAt") },
            ],
          }}
        />
        <Table
          columns={columns}
          dataSource={users}
          rowKey="id"
          loading={loading}
          pagination={{
            current: pagination.currentPage,
            pageSize: pagination.limit,
            total: pagination.totalItems,
            showSizeChanger: true,
            pageSizeOptions: ['10', '20', '50'],
            showTotal: (total, range) => 
              t("users.table.total", { 
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
    </div>
  );
};

export default Users;
