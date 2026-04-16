import React, { useState, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { Form, Input, Button, message, Spin, Card, Typography } from "antd";
import API_BASE_URL from "../../config/apiConfig";
import axios from "axios";
import "./ResetPassword.css"; // Create this CSS file for additional styling

const { Title, Text } = Typography;

const ResetPassword: React.FC = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [tokenValid, setTokenValid] = useState(false);
  const [form] = Form.useForm();

  const token = searchParams.get("token");

  useEffect(() => {
    if (token) {
      validateToken();
    }
  }, [token]);

  const validateToken = async () => {
    try {
      setLoading(true);
      const response = await axios.get(
        `${API_BASE_URL}/api/user/password-reset/validate/${token}`
      );
      
      if (response.status === 200) {
        setTokenValid(true);
        // The backend returns masked email, but we don't need to show it
      } else {
        message.error("Invalid or expired token");
        navigate("/");
      }
    } catch (error) {
      message.error("Invalid or expired token");
      navigate("/");
    } finally {
      setLoading(false);
    }
  };

  const onFinish = async (values: { newPassword: string; confirmPassword: string }) => {
    if (values.newPassword !== values.confirmPassword) {
      message.error("Passwords don't match!");
      return;
    }

    try {
      setLoading(true);
      await axios.post(`${API_BASE_URL}/api/user/password-reset/confirm`, {
        token,
        newPassword: values.newPassword,
      });

      message.success("Password has been reset successfully!");
      navigate("/");
    } catch (error) {
      if (axios.isAxiosError(error)) {
        message.error(error.response?.data?.error || "Failed to reset password");
      } else {
        message.error("An unexpected error occurred");
      }
    } finally {
      setLoading(false);
    }
  };

  if (!token) {
    return (
      <div className="reset-password-container">
        <Card className="reset-password-card">
          <Title level={3} className="text-center">
            Invalid Reset Link
          </Title>
          <Text className="text-center block mb-4">
            The password reset link is missing the token. Please check your email for the correct link.
          </Text>
          <Button type="primary" onClick={() => navigate("/")}>
            Back to Login
          </Button>
        </Card>
      </div>
    );
  }

  if (loading && !tokenValid) {
    return (
      <div className="reset-password-container">
        <Spin tip="Validating token..." size="large" />
      </div>
    );
  }

  return (
    <div className="reset-password-container">
      <Card className="reset-password-card">
        <Title level={3} className="text-center">
          Reset Your Password
        </Title>
        
        <Form
          form={form}
          name="reset_password"
          onFinish={onFinish}
          layout="vertical"
          className="reset-password-form"
        >
          <Form.Item
            name="newPassword"
            label="New Password"
            rules={[
              { required: true, message: "Please input your new password!" },
              { min: 8, message: "Password must be at least 8 characters" },
              {
                pattern: /[A-Z]/,
                message: "Must contain at least one uppercase letter",
              },
              {
                pattern: /[a-z]/,
                message: "Must contain at least one lowercase letter",
              },
              { pattern: /[0-9]/, message: "Must contain at least one number" },
              {
                pattern: /[\W]/,
                message: "Must contain at least one special character",
              },
            ]}
            hasFeedback
          >
            <Input.Password placeholder="Enter new password" />
          </Form.Item>

          <Form.Item
            name="confirmPassword"
            label="Confirm Password"
            dependencies={["newPassword"]}
            hasFeedback
            rules={[
              { required: true, message: "Please confirm your password!" },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue("newPassword") === value) {
                    return Promise.resolve();
                  }
                  return Promise.reject(
                    new Error("The two passwords don't match!")
                  );
                },
              }),
            ]}
          >
            <Input.Password placeholder="Confirm new password" />
          </Form.Item>

          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              block
              loading={loading}
              disabled={!tokenValid}
            >
              Reset Password
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};

export default ResetPassword;