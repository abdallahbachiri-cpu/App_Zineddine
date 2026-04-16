// UserDetails.tsx
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { 
  Card, 
  Avatar, 
  Tag, 
  Button, 
  Space, 
  Typography, 
  Divider, 
  Descriptions, 
  message,
  Breadcrumb,
  Modal,
  Form,
  Input
} from 'antd';
import { 
  UserOutlined, 
  ShopOutlined, 
  CrownOutlined, 
  PhoneOutlined, 
  ArrowLeftOutlined,
  EditOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined
} from '@ant-design/icons';
import { getUserById, updateUser } from '../../services/userService';
import { useTranslation } from 'react-i18next';

const { Title } = Typography;

const UserDetails: React.FC = () => {
  const { t } = useTranslation();
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [form] = Form.useForm();
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    
    const fetchUser = async () => {
      try {
        const response = await getUserById(id!);
        
        setUser(response);        
      } catch (error) {
        message.error(t('userDetails.messages.error'));
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [id, t]);

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

  const handleEditClick = () => {
    form.setFieldsValue({
      firstName: user.firstName,
      lastName: user.lastName,
      middleName: user.middleName || '',
      phoneNumber: user.phoneNumber || ''
    });
    setIsEditModalOpen(true);
  };

  const handleEditSubmit = async (values: any) => {
    try {
      setUpdating(true);
      await updateUser(id!, values);
      message.success(t('userDetails.messages.updateSuccess'));
      
      // Refresh user data
      const updatedUser = await getUserById(id!);
      setUser(updatedUser);
      
      setIsEditModalOpen(false);
      form.resetFields();
    } catch (error) {
      message.error(t('userDetails.messages.updateError'));
    } finally {
      setUpdating(false);
    }
  };

  const handleCancel = () => {
    setIsEditModalOpen(false);
    form.resetFields();
  };

  if (loading) {
    return <div>{t('userDetails.messages.loading')}</div>;
  }

  if (!user) {
    return <div>{t('userDetails.messages.notFound')}</div>;
  }

  return (
    <div className="p-6">
      <Breadcrumb style={{ marginBottom: 24 }}>
        <Breadcrumb.Item className="cursor-pointer" onClick={() => navigate('/users')}>
          {t('userDetails.breadcrumb.users')}
        </Breadcrumb.Item>
        <Breadcrumb.Item>
          {user.firstName} {user.lastName}
        </Breadcrumb.Item>
      </Breadcrumb>

      <Card
        title={
          <Space>
            <Button 
              icon={<ArrowLeftOutlined />} 
              onClick={() => navigate('/users')}
            />
            <Title level={4} style={{ margin: 0 }}>
              {t('userDetails.title')}
            </Title>
          </Space>
        }
        extra={
          <Button 
            type="primary" 
            icon={<EditOutlined />}
            onClick={handleEditClick}
          >
            {t('userDetails.actions.edit')}
          </Button>
        }
      >
        <div style={{ display: 'flex', gap: 24, marginBottom: 24 }}>
          <Avatar 
            size={128} 
            src={user.avatar} 
            icon={<UserOutlined />}
            style={{ 
              backgroundColor: user.type === 'seller' ? '#1890ff' : 
                            user.type === 'admin' ? '#faad14' : '#52c41a',
              fontSize: 48 
            }}
          />
          
          <div>
            <Title level={2}>
              {user.firstName} {user.lastName}
              <Tag 
                icon={getUserTypeIcon(user.type)} 
                color={user.type === 'seller' ? 'blue' : 
                      user.type === 'admin' ? 'gold' : 'green'}
                style={{ marginLeft: 12 }}
              >
                {t(`users.types.${user.type}`)}
              </Tag>
            </Title>
            
            <Space size="middle" style={{ marginBottom: 16 }}>
              {user.phoneNumber && (
                <Button icon={<PhoneOutlined />}>
                  {user.phoneNumber}
                  {user.isPhoneConfirmed && (
                    <Tag color="green" style={{ marginLeft: 8 }}>
                      {t("users.table.status.verified")}
                    </Tag>
                  )}
                </Button>
              )}
            </Space>
          </div>
        </div>

        <Divider />

        <Descriptions title={t('userDetails.sections.basicInfo')} bordered column={2}>
          <Descriptions.Item label={t('userDetails.fields.firstName')}>
            {user.firstName}
          </Descriptions.Item>
          <Descriptions.Item label={t('userDetails.fields.lastName')}>
            {user.lastName}
          </Descriptions.Item>
          <Descriptions.Item label={t('userDetails.fields.phone')}>
            {user.phoneNumber || '-'}
          </Descriptions.Item>
          <Descriptions.Item label={t('userDetails.fields.status')}>
            {user.isDeleted ? (
              <Tag color="red">{t("users.table.status.deleted")}</Tag>
            ) : user.isActive ? (
              <Tag color="green">{t("users.table.status.active")}</Tag>
            ) : (
              <Tag color="orange">{t("users.table.status.suspended")}</Tag>
            )}
          </Descriptions.Item>
          <Descriptions.Item label={t('userDetails.fields.createdAt')}>
            {new Date(user.createdAt).toLocaleString()}
          </Descriptions.Item>
        </Descriptions>

        {user.type === 'seller' && user.foodStoreName && (
          <>
            <Divider />
            <Descriptions title={t('userDetails.sections.sellerInfo')} bordered column={2}>
              <Descriptions.Item label={t('userDetails.fields.foodStore')}>
                <Tag icon={<ShopOutlined />} color="blue">
                  {user.foodStoreName}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="Vendor Agreement">
                <Space direction="vertical" size={0}>
                  <Space>
                    {user.vendorAgreementAccepted ? (
                      <>
                        <CheckCircleOutlined style={{ color: '#52c41a' }} />
                        <Tag color="green">Accepted</Tag>
                      </>
                    ) : 
                      <>
                        <CloseCircleOutlined style={{ color: '#ff4d4f' }} />
                        <Tag color="red">Not Accepted</Tag>
                      </>
                    }
                  </Space>
                  {user.vendorAgreementAcceptedAt && (
                    <div style={{ fontSize: 12, color: '#666' }}>
                      Accepted on: {new Date(user.vendorAgreementAcceptedAt).toLocaleDateString()}
                    </div>
                  )}
                </Space>
              </Descriptions.Item>
            </Descriptions>
          </>
        )}
        <Divider />
        <Space>
          <Button onClick={() => navigate('/users')}>
            {t('userDetails.actions.backToList')}
          </Button>
          <Button type="primary" onClick={handleEditClick}>
            {t('userDetails.actions.editProfile')}
          </Button>
        </Space>
      </Card>

      <Modal
        title={t('userDetails.editModal.title')}
        open={isEditModalOpen}
        onCancel={handleCancel}
        footer={[
          <Button key="cancel" onClick={handleCancel}>
            {t('userDetails.editModal.cancel')}
          </Button>,
          <Button
            key="submit"
            type="primary"
            loading={updating}
            onClick={() => form.submit()}
          >
            {t('userDetails.editModal.save')}
          </Button>,
        ]}
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleEditSubmit}
        >
          <Form.Item
            name="firstName"
            label={t('userDetails.fields.firstName')}
            rules={[{ required: true, message: t('userDetails.validation.firstNameRequired') }]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            name="lastName"
            label={t('userDetails.fields.lastName')}
            rules={[{ required: true, message: t('userDetails.validation.lastNameRequired') }]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            name="middleName"
            label={t('userDetails.fields.middleName')}
          >
            <Input />
          </Form.Item>

          <Form.Item
            name="phoneNumber"
            label={t('userDetails.fields.phone')}
          >
            <Input />
          </Form.Item>
          
        </Form>
      </Modal>
    </div>
  );
};

export default UserDetails;
