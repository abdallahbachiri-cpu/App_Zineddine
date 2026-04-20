import React, { useState } from "react";
import { Card, Form, Input, Button, Select, message, Typography } from "antd";
import { useTranslation } from "react-i18next";
import API from "../../services/httpClient";
import { API_ENDPOINTS } from "../../config/apiConfig";

const { TextArea } = Input;
const { Title, Paragraph } = Typography;

const AdminBroadcastNotification: React.FC = () => {
  const { t } = useTranslation();
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  const handleBroadcast = async (values: any) => {
    setLoading(true);
    try {
      const payload = {
        title: values.title,
        body: values.body,
        title_fr: values.title_fr || null,
        body_fr: values.body_fr || null,
        actionUrl: values.actionUrl || null,
        targetType: values.targetType === "all" ? null : values.targetType,
      };

      await API.post(API_ENDPOINTS.ADMIN.BROADCAST_NOTIFICATIONS, payload);
      message.success("Broadcast notification sent successfully.");
      form.resetFields();
    } catch (error: unknown) {
      if (error instanceof Error) {
        message.error(error.message);
      } else {
        message.error(t("common.unknownError"));
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <Card className="shadow-sm" title="Broadcast Notification">
        <Title level={4}>Send a broadcast notification</Title>
        <Paragraph>
          Use this form to send a push notification to all active users or a specific user group.
        </Paragraph>

        <Form form={form} layout="vertical" onFinish={handleBroadcast}>
          <Form.Item
            label="Notification title"
            name="title"
            rules={[{ required: true, message: "Please enter a title." }]}
          >
            <Input placeholder="Enter title" />
          </Form.Item>

          <Form.Item
            label="Notification body"
            name="body"
            rules={[{ required: true, message: "Please enter a message body." }]}
          >
            <TextArea rows={4} placeholder="Enter message body" />
          </Form.Item>

          <Form.Item label="French title" name="title_fr">
            <Input placeholder="Optional French title" />
          </Form.Item>

          <Form.Item label="French body" name="body_fr">
            <TextArea rows={3} placeholder="Optional French body" />
          </Form.Item>

          <Form.Item label="Action URL" name="actionUrl">
            <Input placeholder="Optional link to open when tapped" />
          </Form.Item>

          <Form.Item label="Target audience" name="targetType" initialValue="all">
            <Select>
              <Select.Option value="all">All users</Select.Option>
              <Select.Option value="buyer">Buyers only</Select.Option>
              <Select.Option value="seller">Sellers only</Select.Option>
            </Select>
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading}>
              Send broadcast
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};

export default AdminBroadcastNotification;
