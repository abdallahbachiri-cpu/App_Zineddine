// src/services/adminOrderService.ts
import API from "./api";

import { AdminOrderResponse, AdminOrder } from "../types/adminOrder";


export const fetchAdminOrders = async (): Promise<AdminOrderResponse> => {
  const response = await API.get('/admin/orders');  
  return response.data;
};

export const fetchAdminOrderById = async (id: string): Promise<AdminOrder> => {
  const response = await API.get(`/admin/orders/${id}`);
  return response.data;
};

export const cancelAdminOrder = async (id: string): Promise<void> => {
  await API.post(`/admin/orders/${id}/cancel`);
};
