import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Card,
  Form,
  Input,
  Button,
  message,
  Typography,
  Space,
  Divider
} from "antd";
import { ArrowLeftOutlined, UserOutlined, MailOutlined, LockOutlined } from "@ant-design/icons";
import { useTranslation } from "react-i18next";
import { createAdmin, type CreateAdminRequest } from "../../services/adminUserService";

const { Title, Text } = Typography;

const CreateAdmin: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (values: CreateAdminRequest) => {
    setLoading(true);
    try {
      await createAdmin(values);
      message.success(t("createAdmin.messages.success") || "Admin user created successfully");
      form.resetFields();
      // Optionally navigate to admin users list or stay on page
      // navigate("/admin/users");
    } catch (error: any) {
      console.error("Failed to create admin user:", error);
      const errorMessage = error?.response?.data?.message || error?.message || t("createAdmin.messages.error") || "Failed to create admin user";
      message.error(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleBack = () => {
    navigate(-1);
  };

  return (
    <div className="p-6">
      <Card bordered={false}>
        <div className="mb-6">
          <Space align="center" className="mb-4">
            <Button 
              icon={<ArrowLeftOutlined />} 
              onClick={handleBack}
              type="text"
            >
              {t("common.back") || "Back"}
            </Button>
            <Title level={2} className="mb-0">
              {t("createAdmin.title") || "Create New Admin"}
            </Title>
          </Space>
          <Text type="secondary">
            {t("createAdmin.description") || "Fill in the form below to create a new administrator account"}
          </Text>
        </div>

        <Divider />

        <Form
          form={form}
          layout="vertical"
          onFinish={handleSubmit}
          size="large"
          className="max-w-2xl"
        >
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Form.Item
              name="firstName"
              label={t("createAdmin.form.firstName") || "First Name"}
              rules={[
                { required: true, message: t("createAdmin.validation.firstNameRequired") || "Please input first name!" },
                { min: 2, message: t("createAdmin.validation.firstNameMin") || "First name must be at least 2 characters!" },
                { max: 50, message: t("createAdmin.validation.firstNameMax") || "First name must be less than 50 characters!" }
              ]}
            >
              <Input
                prefix={<UserOutlined />}
                placeholder={t("createAdmin.form.firstNamePlaceholder") || "Enter first name"}
              />
            </Form.Item>

            <Form.Item
              name="lastName"
              label={t("createAdmin.form.lastName") || "Last Name"}
              rules={[
                { required: true, message: t("createAdmin.validation.lastNameRequired") || "Please input last name!" },
                { min: 2, message: t("createAdmin.validation.lastNameMin") || "Last name must be at least 2 characters!" },
                { max: 50, message: t("createAdmin.validation.lastNameMax") || "Last name must be less than 50 characters!" }
              ]}
            >
              <Input
                prefix={<UserOutlined />}
                placeholder={t("createAdmin.form.lastNamePlaceholder") || "Enter last name"}
              />
            </Form.Item>
          </div>

          <Form.Item
            name="email"
            label={t("createAdmin.form.email") || "Email"}
            rules={[
              { required: true, message: t("createAdmin.validation.emailRequired") || "Please input email!" },
              { type: "email", message: t("createAdmin.validation.emailInvalid") || "Please enter a valid email!" }
            ]}
          >
            <Input
              prefix={<MailOutlined />}
              placeholder={t("createAdmin.form.emailPlaceholder") || "Enter email address"}
            />
          </Form.Item>

          <Form.Item
            name="password"
            label={t("createAdmin.form.password") || "Password"}
            rules={[
              { required: true, message: t("createAdmin.validation.passwordRequired") || "Please input password!" },
              { min: 8, message: t("createAdmin.validation.passwordMin") || "Password must be at least 8 characters!" },
              { max: 128, message: t("createAdmin.validation.passwordMax") || "Password must be less than 128 characters!" },
              {
                pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
                message: t("createAdmin.validation.passwordPattern") || "Password must contain at least one uppercase letter, one lowercase letter, and one number!"
              }
            ]}
          >
            <Input.Password
              prefix={<LockOutlined />}
              placeholder={t("createAdmin.form.passwordPlaceholder") || "Enter password"}
            />
          </Form.Item>

          <Form.Item
            name="confirmPassword"
            label={t("createAdmin.form.confirmPassword") || "Confirm Password"}
            dependencies={["password"]}
            rules={[
              { required: true, message: t("createAdmin.validation.confirmPasswordRequired") || "Please confirm password!" },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue("password") === value) {
                    return Promise.resolve();
                  }
                  return Promise.reject(new Error(t("createAdmin.validation.passwordMismatch") || "Passwords do not match!"));
                },
              }),
            ]}
          >
            <Input.Password
              prefix={<LockOutlined />}
              placeholder={t("createAdmin.form.confirmPasswordPlaceholder") || "Confirm password"}
            />
          </Form.Item>

          <Divider />

          <Form.Item className="mb-0">
            <Space size="large">
              <Button
                type="primary"
                htmlType="submit"
                loading={loading}
                size="large"
                className="px-8"
              >
                {loading 
                  ? (t("createAdmin.form.creating") || "Creating...")
                  : (t("createAdmin.form.createButton") || "Create Admin")
                }
              </Button>
              <Button
                onClick={handleBack}
                size="large"
                className="px-8"
              >
                {t("common.cancel") || "Cancel"}
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};

export default CreateAdmin;