import React, { useState } from 'react';
import { Dish } from '../types/menu';
import { Form, Input, InputNumber, Upload, Button, Modal, message } from 'antd';
import { UploadOutlined, CloseOutlined } from '@ant-design/icons';
import type { UploadFile } from 'antd/es/upload/interface';
import { useTranslation } from 'react-i18next';

interface AddDishFormProps {
  onClose: () => void;
  onAddDish: (dish: Omit<Dish, 'id'>, files: File[]) => Promise<void>;
}

const AddDishForm: React.FC<AddDishFormProps> = ({ onClose, onAddDish }) => {
  const { t } = useTranslation();
  const [form] = Form.useForm();
  const [fileList, setFileList] = useState<File[]>([]);
  const [uploadFileList, setUploadFileList] = useState<UploadFile[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleFileChange = (info: any) => {
    if (info.fileList) {
      // Update the file list for form submission
      const newFileList = info.fileList.map((file: any) => file.originFileObj);
      setFileList(newFileList);
      
      // Update the upload component's file list
      const newUploadFileList = info.fileList.map((file: any, index: number) => ({
        uid: `-${index}`,
        name: file.originFileObj.name,
        status: 'done',
        url: file.url || URL.createObjectURL(file.originFileObj),
      }));
      setUploadFileList(newUploadFileList);
    }
  };

  const onFinish = async (values: Omit<Dish, 'id'>) => {
    try {
      setIsSubmitting(true);
      await onAddDish(
        {
          name: values.name,
          description: values.description,
          price: values.price,
          gallery: [],
          foodStoreId: '',
          foodStoreName: '',
          available: false,
          averageRating: 0,
          createdAt: '',
          updatedAt: ''
        },
        fileList
      );
      form.resetFields();
      setFileList([]);
      setUploadFileList([]);
      onClose();
    } catch (err: any) {
      message.error(err.message || t('dish.detail.messages.addError'));
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Modal
      title={t('dish.addForm.title')?t('dish.addForm.title'):"tesr"}
      open={true}
      onCancel={onClose}
      footer={null}
      width={600}
      closeIcon={<CloseOutlined />}
      style={{ top: '10px' }}
    >
      <Form
        form={form}
        layout="vertical"
        onFinish={onFinish}
        className="mt-6"
      >
        <Form.Item
          label={t('dish.addForm.fields.name')}
          name="name"
          rules={[{ 
            required: true, 
            message: t('dish.addForm.validation.nameRequired') 
          }]}
        >
          <Input placeholder={t('dish.addForm.placeholders.name')} />
        </Form.Item>

        <Form.Item
          label={t('dish.addForm.fields.description')}
          name="description"
        >
          <Input.TextArea 
            rows={4} 
            placeholder={t('dish.addForm.placeholders.description')} 
          />
        </Form.Item>

        <Form.Item
          label={t('dish.addForm.fields.price')}
          name="price"
          rules={[{ 
            required: true, 
            message: t('dish.addForm.validation.priceRequired') 
          }]}
        >
          <InputNumber 
            min={0} 
            step={0.01} 
            style={{ width: '100%' }} 
            placeholder={t('dish.addForm.placeholders.price')} 
          />
        </Form.Item>

        <Form.Item
          label={t('dish.addForm.fields.images')}
          name="images"
        >
          <Upload
            multiple
            beforeUpload={() => false}
            onChange={handleFileChange}
            fileList={uploadFileList}
            accept="image/*"
          >
            <Button icon={<UploadOutlined />}>
              {t('dish.addForm.buttons.chooseFiles')}
            </Button>
          </Upload>
          <div className="text-gray-500 text-sm mt-1">
            {fileList.length > 0 
              ? t('dish.addForm.buttons.filesChosen', { count: fileList.length })
              : t('dish.addForm.buttons.noFiles')}
          </div>
        </Form.Item>

        <Form.Item className="flex justify-end gap-2 mt-6">
          <Button onClick={onClose} disabled={isSubmitting}>
            {t('dish.addForm.buttons.cancel')}
          </Button>
          <Button 
            type="primary" 
            htmlType="submit"
            loading={isSubmitting}
          >
            {t('dish.addForm.buttons.addDish')}
          </Button>
        </Form.Item>
      </Form>
    </Modal>
  );
};

export default AddDishForm;