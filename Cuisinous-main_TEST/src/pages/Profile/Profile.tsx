import React, { useState, useEffect } from "react";
import { Form, Input, Button, Upload, message, Avatar, Card, Spin } from "antd";
import { UserOutlined, EditOutlined } from "@ant-design/icons";
import type { UploadProps } from 'antd';
import API from "../../services/api";
import { API_BASE_URL } from "../../config/apiConfig";
import { useTranslation } from "react-i18next";

interface UserData {
  email: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  middleName?: string;
  username?: string;
  profileImage?: string;
  profileImageUrl?: string;
}

const Profile: React.FC = () => {
  const { t } = useTranslation();
  const [profileData, setProfileData] = useState<UserData>({
    email: "",
    firstName: "",
    lastName: "",
    phoneNumber: "",
    middleName: "",
  });
  const [form] = Form.useForm();
  const [isLoading, setIsLoading] = useState(false);
  const [imageLoading, setImageLoading] = useState(false);
  const [, setError] = useState<string | null>(null);
  const [, setSuccess] = useState(false);

  useEffect(() => {
    const userData = localStorage.getItem("user");
    if (userData) {
      try {
        const parsedData = JSON.parse(userData);
        setProfileData({
          email: parsedData.email,
          firstName: parsedData.firstName || "",
          lastName: parsedData.lastName || "",
          phoneNumber: parsedData.phoneNumber || "",
          middleName: parsedData.middleName || "",
          username: parsedData.username || "",
          profileImage: parsedData.profileImage || null,
          profileImageUrl: parsedData.profileImageUrl || null,
        });
        form.setFieldsValue(parsedData);
      } catch (err) {
        console.error("Error parsing user data:", err);
        setError("Failed to load user data");
      }
    }
  }, [form]);

  const handleImageUpload: UploadProps['onChange'] = async (info) => {
    if (info.file.status === 'uploading') {
      setImageLoading(true);
      return;
    }

    if (info.file.status === 'done') {
      try {
        const formData = new FormData();
        formData.append('profileImage', info.file.originFileObj as Blob);

        const response = await API.post('/user/profile-image', formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        });

        // Update local storage and state
        const updatedUser = {
          ...JSON.parse(localStorage.getItem("user") || "{}"),
          profileImage: response.data.profileImageUrl
        };
        localStorage.setItem("user", JSON.stringify(updatedUser));
        
        setProfileData(prev => ({
          ...prev,
          profileImage: response.data.profileImageUrl
        }));
        
        message.success(t('profile.image.success'));
      } catch (err) {
        console.error("Error uploading image:", err);
        message.error(t('profile.image.error'));
      } finally {
        setImageLoading(false);
      }
    }

    if (info.file.status === 'error') {
      setImageLoading(false);
      message.error(t('profile.image.error'));
    }
  };

  const handleSave = async (values: UserData) => {
    setIsLoading(true);
    setError(null);
    setSuccess(false);
    
    try {
      const payload = {
        firstName: values.firstName,
        lastName: values.lastName,
        phoneNumber: values.phoneNumber,
        ...(values.middleName && { middleName: values.middleName }),
      };

      const response = await API.patch("/user", payload);

      // Update localStorage with new data
      const updatedUser = {
        ...JSON.parse(localStorage.getItem("user") || "{}"),
        ...response.data
      };
      localStorage.setItem("user", JSON.stringify(updatedUser));

      setProfileData(updatedUser);
      message.success(t('profile.form.success'));
    } catch (err) {
      console.error("Error updating profile:", err);
      message.error(t('profile.form.error'));
    } finally {
      setIsLoading(false);
    }
  };

  const beforeImageUpload = (file: File) => {
    const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png';
    if (!isJpgOrPng) {
      message.error(t('profile.image.validation.format'));
    }
    const isLt2M = file.size / 1024 / 1024 < 2;
    if (!isLt2M) {
      message.error(t('profile.image.validation.size'));
    }
    return isJpgOrPng && isLt2M;
  };
  
  return (
    <div className="p-6 max-w-4xl mx-auto">
      <Card
        title={<h1 className="text-2xl font-bold">{t('profile.title')}</h1>}
        bordered={false}
        className="shadow-sm"
      >
        <div className="flex flex-col md:flex-row gap-8">
          <div className="flex flex-col items-center w-full md:w-1/3">
            <Spin spinning={imageLoading}>
              <Upload
                name="profileImage"
                showUploadList={false}
                beforeUpload={beforeImageUpload}
                onChange={handleImageUpload}
                customRequest={({ onSuccess }) => {
                  setTimeout(() => {
                    onSuccess?.('ok');
                  }, 0);
                }}
                className="mb-4"
              >
                <div className="relative">
                  <Avatar
                    size={128}
                    icon={<UserOutlined />}
                    src={`${API_BASE_URL}${profileData.profileImageUrl}`}
                    className="border-2 border-gray-200"
                  />
                  <div className="absolute bottom-0 right-0 bg-white p-2 rounded-full shadow-md">
                    <EditOutlined className="text-gray-600" />
                  </div>
                </div>
              </Upload>
            </Spin>
            <p className="text-gray-500 text-sm mt-2">
              {t('profile.image.uploadText')}
            </p>
          </div>

          <div className="w-full md:w-2/3">
            <Form
              form={form}
              layout="vertical"
              onFinish={handleSave}
              initialValues={profileData}
            >
              {profileData.username && (
                <Form.Item label={t('profile.form.username.label')}>
                  <Input value={profileData.username} disabled />
                  <p className="text-gray-500 text-xs mt-1">
                    {t('profile.form.username.help')}
                  </p>
                </Form.Item>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Form.Item
                  label={t('profile.form.firstName.label')}
                  name="firstName"
                  rules={[{ required: true, message: t('profile.form.firstName.error') }]}
                >
                  <Input />
                </Form.Item>

                <Form.Item
                  label={t('profile.form.lastName.label')}
                  name="lastName"
                  rules={[{ required: true, message: t('profile.form.lastName.error') }]}
                >
                  <Input />
                </Form.Item>

                <Form.Item
                  label={t('profile.form.middleName.label')}
                  name="middleName"
                >
                  <Input />
                </Form.Item>

                <Form.Item
                  label={t('profile.form.email.label')}
                >
                  <Input value={profileData.email} disabled />
                </Form.Item>

                <Form.Item
                  label={t('profile.form.phoneNumber.label')}
                  name="phoneNumber"
                  rules={[{ required: true, message: t('profile.form.phoneNumber.error') }]}
                >
                  <Input />
                </Form.Item>
              </div>

              <Form.Item className="mt-6">
                <Button
                  type="primary"
                  htmlType="submit"
                  loading={isLoading}
                  className="w-full md:w-auto"
                >
                  {t('profile.form.saveButton')}
                </Button>
              </Form.Item>
            </Form>
          </div>
        </div>
      </Card>
    </div>
  );
};

export default Profile;