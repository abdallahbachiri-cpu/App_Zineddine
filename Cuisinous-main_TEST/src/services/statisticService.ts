import API from "./api";
import { API_ENDPOINTS } from "../config/apiConfig";

export const getBasicStats = async () => {
  
  const response = await API.get(API_ENDPOINTS.SELLER_STATISTICS);
  return response.data;
};

// Revenue statistics functions
export const getRevenueByYear = async () => {
  const response = await API.get(API_ENDPOINTS.SELLER_REVENUE_BY_YEAR);
  return response.data;
};

export const getRevenueByMonth = async (year: number) => {
  const response = await API.get(`${API_ENDPOINTS.SELLER_REVENUE_BY_MONTH}/${year}`);
  return response.data;
};

export const getRevenueByDay = async (year: number, month: number) => {
  const response = await API.get(`${API_ENDPOINTS.SELLER_REVENUE_BY_DAY}/${year}/${month}`);
  return response.data;
};

// Admin statistics functions
export const getAdminBasicStats = async () => {
  const response = await API.get(API_ENDPOINTS.ADMIN.ADMIN_STATISTICS);
  return response.data;
};

export const getAdminRevenueByYear = async () => {
  const response = await API.get(API_ENDPOINTS.ADMIN.ADMIN_REVENUE_BY_YEAR);
  return response.data;
};

export const getAdminRevenueByMonth = async (year: number) => {
  const response = await API.get(`${API_ENDPOINTS.ADMIN.ADMIN_REVENUE_BY_MONTH}/${year}`);
  return response.data;
};

export const getAdminRevenueByDay = async (year: number, month: number) => {
  const response = await API.get(`${API_ENDPOINTS.ADMIN.ADMIN_REVENUE_BY_DAY}/${year}/${month}`);
  return response.data;
};

export const updateFoodStore = async (storeData: any) => {  
  
  const response = await API.patch("/seller/food-store", storeData);
  return response.data;
};

export const updateFoodStoreImage = async (storeData: FormData) => {
  const response = await API.post("/seller/food-store/profile-image", storeData, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
  return response.data;
};

export const deleteFoodStore = async () => {
  const response = await API.delete("/seller/food-store");
  return response.data;
};
