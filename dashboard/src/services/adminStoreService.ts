import api from './httpClient';

export interface FoodStoreData {
  id: string;
  name: string;
  description?: string;
  profileImageUrl?: string;
  address: {
    id: string;
    latitude: number;
    longitude: number;
    street?: string;
    city?: string;
    state?: string;
    zipCode?: string;
    country?: string;
    additionalDetails?: string;
  };
  sellerId: string;
  sellerName?: string;
  sellerEmail?: string;
  isActive: boolean;
  isVerified: boolean;
  isStripeConnected: boolean;
  vendorAgreementAccepted: boolean;
  vendorAgreementAcceptedAt?: string;
  deliveryOption: string;
  type: string;
  createdAt: string;
  updatedAt: string;
  dishes?: DishData[];
}

export interface DishData {
  id: string;
  name: string;
  description?: string;
  price: number;
  category?: string;
  gallery?: Array<GalleryImageData>;
  available: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface GalleryImageData {
  id: string;
  url: string;
  filename: string;
  mimeType: string;
  size: number;
  createdAt: string;
  updatedAt: string;
}

export interface FoodStoreListResponse {
  data: FoodStoreData[];
  total_items: number;
  total_pages: number;
  current_page: number;
  limit: number;
}

export interface FoodStoreSearchParams {
  search?: string;
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'ASC' | 'DESC';
  isActive?: boolean;
  isVerified?: boolean;
}

// Get all food stores with search and filtering
export const getFoodStores = async (params: FoodStoreSearchParams = {}): Promise<FoodStoreListResponse> => {
  const response = await api.get("/admin/food-stores", { params });
  return response.data;
};

// Get a food store by ID
export const getFoodStoreById = async (id: string): Promise<FoodStoreData> => {
  const response = await api.get(`/admin/food-stores/${id}`);
  return response.data;
};

// Get dishes for a food store
export const getFoodStoreDishes = async (id: string): Promise<DishData[]> => {
  const response = await api.get(`/admin/food-stores/${id}/dishes`);
  return response.data.data || response.data;
};

// Delete food store
export const deleteFoodStore = async (id: string): Promise<void> => {
  await api.delete(`/admin/food-stores/${id}`);
};