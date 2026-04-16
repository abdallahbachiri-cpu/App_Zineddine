import { message } from 'antd';
import API from './api';
// import { Category, CategoryCreateDTO, CategoryUpdateDTO } from '../../types/Category';
import { CategoryCreateDTO, CategoryUpdateDTO } from '../types/category';


export const CategoryService = {
  async getAllCategories(params: {
    page?: number;
    limit?: number;
    sortBy?: string;
    sortOrder?: string;
    search?: string;
    type?: string;
  }) {
    try {
      const queryParams = new URLSearchParams();
      Object.entries(params).forEach(([key, value]) => {
        if (value) queryParams.append(key, String(value));
      });

      const response = await API.get(`/admin/categories?${queryParams}`);
      return await response.data;
    } catch (error) {
      message.error('Failed to fetch categories');
      throw error;
    }
  },

  async createCategory(data: CategoryCreateDTO) {
    try {
      const response = await API.post('/admin/categories', data);
      message.success('Category created successfully');
      return await response.data;
    } catch (error) {
      message.error('Failed to create category');
      throw error;
    }
  },

  async updateCategory(id: string, data: CategoryUpdateDTO) {
    try {
      const response = await API.patch(`admin/categories/${id}`, data);
      message.success('Category updated successfully');
      return await response.data;
    } catch (error) {
      message.error('Failed to update category');
      throw error;
    }
  },

  async deleteCategory(id: string) {
    try {
      await API.delete(`/admin/categories/${id}`);
      message.success('Category deleted successfully');
    } catch (error) {
      message.error('Failed to delete category');
      throw error;
    }
  },

  async getCategoryTypes() {
    try {
      const response = await API.get('/admin/category-types');
      return await response.data;
    } catch (error) {
      message.error('Failed to fetch category types');
      throw error;
    }
  }
};