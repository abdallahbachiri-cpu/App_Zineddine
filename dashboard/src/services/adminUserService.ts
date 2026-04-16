import api from './httpClient';

export interface CreateAdminRequest {
  email: string;
  firstName: string;
  lastName: string;
  password: string;
  locale: string;
}

export interface AdminUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phoneNumber?: string;
  type: "admin";
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreateAdminResponse {
  message: string;
  user: AdminUser;
}

// Create a new admin user
export const createAdmin = async (adminData: CreateAdminRequest): Promise<CreateAdminResponse> => {
  const response = await api.post("/admin/users/admin", adminData);
  return response.data;
};

// Get all admin users (optional, for future use)
export const getAdminUsers = async (): Promise<AdminUser[]> => {
  const response = await api.get("/admin/users/admin");
  return response.data.data || response.data;
};