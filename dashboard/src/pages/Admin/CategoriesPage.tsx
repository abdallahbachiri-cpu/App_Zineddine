import React, { useEffect, useState } from 'react';
import { Table, Button, Space, Input, Select, Modal, Form, message } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { useTranslation } from 'react-i18next';
import { CategoryService } from '../../services/categoryService';
import { Category, CategoryType } from '../../types/category';

const { Search } = Input;
const { Option } = Select;

const CategoriesPage: React.FC = () => {
  const { t } = useTranslation();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [categoryTypes, setCategoryTypes] = useState<CategoryType[]>([]);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [form] = Form.useForm();
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);

  const fetchCategories = async (params: any = {}) => {
    setLoading(true);
    try {
      const { page = 1, limit = 10, ...filters } = params;
      const data = await CategoryService.getAllCategories({
        page,
        limit,
        ...filters,
      });
      setCategories(data.data);
      setPagination({
        current: data.current_page,
        pageSize: data.limit,
        total: data.total_items,
      });
    } catch (error) {
      message.error(t('categories.fetchError'));
    } finally {
      setLoading(false);
    }
  };

  const fetchCategoryTypes = async () => {
    try {
      const types = await CategoryService.getCategoryTypes();
      setCategoryTypes(types);
    } catch (error) {
      message.error(t('categories.typesFetchError'));
    }
  };

  useEffect(() => {
    fetchCategories();
    fetchCategoryTypes();
  }, []);

  const handleTableChange = (pagination: any, filters: any, sorter: any) => {
    fetchCategories({
      page: pagination.current,
      limit: pagination.pageSize,
      type: filters.type?.[0],
      sortBy: sorter.field,
      sortOrder: sorter.order === 'ascend' ? 'ASC' : 'DESC',
    });
  };

  const handleSearch = (value: string) => {
    fetchCategories({ search: value });
  };

  const handleTypeFilter = (value: string) => {
    fetchCategories({ type: value });
  };

  const showCreateModal = () => {
    setEditingCategory(null);
    form.resetFields();
    setIsModalVisible(true);
  };

  const showEditModal = (category: Category) => {
    setEditingCategory(category);
    form.setFieldsValue(category);
    setIsModalVisible(true);
  };

  const handleSubmit = async () => {
    try {
      const values = await form.validateFields();
      if (editingCategory) {
        await CategoryService.updateCategory(editingCategory.id, values);
        message.success(t('categories.updateSuccess'));
      } else {
        await CategoryService.createCategory(values);
        message.success(t('categories.createSuccess'));
      }
      setIsModalVisible(false);
      fetchCategories();
    } catch (error) {
      message.error(t('categories.submitError'));
    }
  };

  const handleDelete = async (id: string) => {
    Modal.confirm({
      title: t('categories.deleteTitle'),
      content: t('categories.deleteContent'),
      okText: t('categories.delete'),
      okType: 'danger',
      cancelText: t('common.cancel'),
      onOk: async () => {
        try {
          await CategoryService.deleteCategory(id);
          message.success(t('categories.deleteSuccess'));
          fetchCategories();
        } catch (error) {
          message.error(t('categories.deleteError'));
        }
      },
    });
  };

  const columns = [
    {
      title: t('categories.columns.nameEn'),
      dataIndex: 'nameEn',
      key: 'nameEn',
      sorter: true,
    },
    {
      title: t('categories.columns.nameFr'),
      dataIndex: 'nameFr',
      key: 'nameFr',
      sorter: true,
    },
    {
      title: t('categories.columns.type'),
      dataIndex: 'type',
      key: 'type',
      filters: categoryTypes.map(type => ({
        text: type.label,
        value: type.value,
      })),
      render: (type: string) => {
        const typeObj = categoryTypes.find(t => t.value === type);
        return typeObj ? typeObj.label : type;
      },
    },
    {
      title: t('categories.columns.actions'),
      key: 'actions',
      render: (_: any, record: Category) => (
        <Space size="middle">
          <Button 
            type="link" 
            icon={<EditOutlined />} 
            onClick={() => showEditModal(record)}
            aria-label={t('categories.edit')}
          />
          <Button 
            type="link" 
            danger 
            icon={<DeleteOutlined />} 
            onClick={() => handleDelete(record.id)}
            aria-label={t('categories.delete')}
          />
        </Space>
      ),
    },
  ];

  return (
    <div>
      <div style={{ marginBottom: 16 }}>
        <Space>
          <Search 
            placeholder={t('categories.searchPlaceholder')} 
            onSearch={handleSearch} 
            style={{ width: 300 }} 
          />
          <Select
            placeholder={t('categories.typeFilterPlaceholder')}
            style={{ width: 200 }}
            onChange={handleTypeFilter}
            allowClear
          >
            {categoryTypes.map(type => (
              <Option key={type.value} value={type.value}>
                {type.label}
              </Option>
            ))}
          </Select>
          <Button 
            type="primary" 
            icon={<PlusOutlined />} 
            onClick={showCreateModal}
          >
            {t('categories.newCategory')}
          </Button>
        </Space>
      </div>

      <Table
        columns={columns}
        dataSource={categories}
        rowKey="id"
        loading={loading}
        pagination={pagination}
        onChange={handleTableChange}
        locale={{
          emptyText: t('categories.noCategories')
        }}
      />

      <Modal
        title={editingCategory ? t('categories.editTitle') : t('categories.createTitle')}
        visible={isModalVisible}
        onOk={handleSubmit}
        onCancel={() => setIsModalVisible(false)}
        okText={t('common.save')}
        cancelText={t('common.cancel')}
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="nameEn"
            label={t('categories.form.nameEn')}
            rules={[{ required: true, message: t('categories.form.nameEnRequired') }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            name="nameFr"
            label={t('categories.form.nameFr')}
            rules={[{ required: true, message: t('categories.form.nameFrRequired') }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            name="type"
            label={t('categories.form.type')}
            rules={[{ required: true, message: t('categories.form.typeRequired') }]}
          >
            <Select>
              {categoryTypes.map(type => (
                <Select.Option key={type.value} value={type.value}>
                  {type.label}
                </Select.Option>
              ))}
            </Select>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default CategoriesPage;