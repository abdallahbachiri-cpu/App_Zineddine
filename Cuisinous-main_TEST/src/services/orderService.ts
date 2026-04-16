// src/services/orderService.ts
import API from "./api";


export const fetchOrders = async () => {
  const response = await API.get('/seller/food-store/orders');
  return response.data;
};

export const fetchOrderById = async (id: string) => {
  const response = await API.get(`/seller/food-store/orders/${id}`);
  return response.data;
};

export const confirmOrder = async (id: string) => {
  const response = await API.post(`/seller/food-store/orders/${id}/confirm`);
  return response.data;
};

export const cancelOrder = async (id: string) => {
  const response = await API.post(`/seller/food-store/orders/${id}/cancel`);
  return response.data;
};

export const fetchOrderByIdForOrders = async (id: string) => {
  const response = await API.get(`/seller/food-store/orders/${id}`);
  return response.data;
};