import React, { useState, useEffect, useCallback } from "react";
import {
  Card,
  Typography,
  Tag,
  Button,
  Space,
  Descriptions,
  Image,
  message,
  Spin,
  Breadcrumb,
  Row,
  Col,
  Avatar
} from "antd";
import { useParams, useNavigate, Link } from "react-router-dom";
import {
  getFoodStoreById,
  type FoodStoreData,
} from "../../services/adminFoodStoreService";
import { useTranslation } from "react-i18next";
import {
  ShopOutlined,
  EyeOutlined,
  CloseCircleOutlined,
  StopOutlined,
  PlayCircleOutlined,
  CalendarOutlined,
  ArrowLeftOutlined,
  HomeOutlined,
  EnvironmentOutlined,
  CarOutlined,
  BankOutlined,
  GlobalOutlined
} from '@ant-design/icons';
import API_BASE_URL from "../../config/apiConfig";

const { Title, Text } = Typography;

const AdminFoodStoreDetail: React.FC = () => {
  const { t } = useTranslation();
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const [foodStore, setFoodStore] = useState<FoodStoreData | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchFoodStoreDetails = useCallback(async () => {
    if (!id) return;

    setLoading(true);
    try {
      const [storeDetails] = await Promise.all([
        getFoodStoreById(id)
      ]);

      setFoodStore(storeDetails);
    } catch (error) {
      console.error("Failed to fetch food store details", error);
      message.error(t("foodStores.messages.error") || "Failed to fetch food store details");
    } finally {
      setLoading(false);
    }
  }, [id, t]);

  useEffect(() => {
    fetchFoodStoreDetails();
  }, [fetchFoodStoreDetails]);


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
        <Breadcrumb.Item>{foodStore.name}</Breadcrumb.Item>
      </Breadcrumb>

      <Row gutter={[16, 16]} className="mb-4">
        <Col>
          <Button
            icon={<ArrowLeftOutlined />}
            onClick={() => navigate('/admin-food-stores')}
          >
            {t("common.back")}
          </Button>
        </Col>
        <Col>
          <Button
            icon={<EyeOutlined />}
            onClick={() => navigate(`/admin-food-stores/${id}/dishes`)}
          >
            {t("foodStores.viewDishes")}
          </Button>
        </Col>
      </Row>

      <Row gutter={[16, 16]}>
        <Col xs={24} lg={16}>
          <Card title={t("foodStores.details.storeInformation")} bordered={false}>
            <Descriptions bordered column={2}>
              <Descriptions.Item label={t("foodStores.details.name")} span={2}>
                <Space>
                  {foodStore.profileImageUrl && (
                    <Avatar
                      size={64}
                      src={`${API_BASE_URL}${foodStore.profileImageUrl}`}
                      alt={foodStore.name}
                      icon={<ShopOutlined />}
                    />
                  )}
                  <div>
                    <Title level={4} style={{ margin: 0 }}>{foodStore.name}</Title>
                    {foodStore.description && (
                      <Text type="secondary">{foodStore.description}</Text>
                    )}
                  </div>
                </Space>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.status")}>
                <Space direction="vertical">
                  <Tag color={foodStore.isActive ? "green" : "orange"} icon={foodStore.isActive ? <PlayCircleOutlined /> : <StopOutlined />}>
                    {foodStore.isActive ?
                      (t("foodStores.status.active")) :
                      (t("foodStores.status.inactive") )
                    }
                  </Tag>
                </Space>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.stripeConnection")}>
                <Tag color={foodStore.isStripeConnected ? "green" : "red"} icon={foodStore.isStripeConnected ? <BankOutlined /> : <CloseCircleOutlined />}>
                  {foodStore.isStripeConnected ?
                    (t("foodStores.stripe.connected")) :
                    (t("foodStores.stripe.notConnected"))
                  }
                </Tag>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.deliveryOption")}>
                <Tag color="blue" icon={<CarOutlined />}>
                  {foodStore.deliveryOption === "pickup_only" 
                    ? (t("foodStores.delivery.pickupOnly"))
                    : foodStore.deliveryOption === "delivery_only"
                    ? (t("foodStores.delivery.deliveryOnly"))
                    : foodStore.deliveryOption === "both"
                    ? (t("foodStores.delivery.both"))
                    : foodStore.deliveryOption
                  }
                </Tag>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.type")}>
                <Tag color="purple" icon={<ShopOutlined />}>
                  {foodStore.type === "home" 
                    ? (t("foodStores.type.home") || "Home Kitchen")
                    : foodStore.type === "restaurant"
                    ? (t("foodStores.type.restaurant") || "Restaurant")
                    : foodStore.type === "catering"
                    ? (t("foodStores.type.catering") || "Catering")
                    : foodStore.type
                  }
                </Tag>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.vendorAgreement")}>
                <Space direction="vertical" size={0}>
                  <Tag color={foodStore.vendorAgreementAccepted ? "green" : "red"}>
                    {foodStore.vendorAgreementAccepted ?
                      (t("foodStores.vendorAgreement.accepted")) :
                      (t("foodStores.vendorAgreement.notAccepted"))
                    }
                  </Tag>
                  {foodStore.vendorAgreementAcceptedAt && (
                    <Text type="secondary" style={{ fontSize: 12 }}>
                      <CalendarOutlined /> {new Date(foodStore.vendorAgreementAcceptedAt).toLocaleDateString()}
                    </Text>
                  )}
                </Space>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.address")} span={2}>
                <Space direction="vertical" size={0}>
                  <Space>
                    <EnvironmentOutlined />
                    <Text strong>
                      {foodStore.address.street && `${foodStore.address.street}, `}
                      {foodStore.address.city && `${foodStore.address.city}, `}
                      {foodStore.address.state && `${foodStore.address.state}, `}
                      {foodStore.address.zipCode && `${foodStore.address.zipCode}, `}
                      {foodStore.address.country}
                    </Text>
                  </Space>
                  {foodStore.address.additionalDetails && (
                    <Text type="secondary" italic>
                      {foodStore.address.additionalDetails}
                    </Text>
                  )}
                  {foodStore.address.latitude && foodStore.address.longitude && (
                    <Space>
                      <GlobalOutlined />
                      <Text type="secondary" style={{ fontSize: 12 }}>
                        {`${foodStore.address.latitude.toFixed(6)}, ${foodStore.address.longitude.toFixed(6)}`}
                      </Text>
                    </Space>
                  )}
                </Space>
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.createdAt")}>
                {new Date(foodStore.createdAt).toLocaleDateString()}
              </Descriptions.Item>

              <Descriptions.Item label={t("foodStores.details.updatedAt")}>
                {new Date(foodStore.updatedAt).toLocaleDateString()}
              </Descriptions.Item>
            </Descriptions>
          </Card>
        </Col>

        <Col xs={24} lg={8}>
          <Card title={t("foodStores.details.profileImage")} bordered={false}>
            {foodStore.profileImageUrl ? (
              <Image
                width="100%"
                src={`${API_BASE_URL}${foodStore.profileImageUrl}`}
                alt={foodStore.name}
                style={{ borderRadius: 8 }}
              />
            ) : (
              <div className="text-center py-8">
                <ShopOutlined style={{ fontSize: 48, color: '#ccc' }} />
                <div className="mt-2">
                  <Text type="secondary">{t("foodStores.noImage")}</Text>
                </div>
              </div>
            )}
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default AdminFoodStoreDetail;