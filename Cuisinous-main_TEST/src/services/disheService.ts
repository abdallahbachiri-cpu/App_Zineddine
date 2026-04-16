// src/api/dishes.ts
import { Dish, Allergen, DishAllergen } from "../types/dishes";
import API from "./api";
import { API_ENDPOINTS } from "../config/apiConfig";

export const getDishes = async (): Promise<Dish[]> => {
  const response = await API.get("/seller/food-store/dishes");

  return response.data;
};

export const createDish = async (
  dishData: Omit<Dish, "id">,
  files: File[]
): Promise<Dish> => {
  const formData = new FormData();

  // Append dish data
  formData.append("name", dishData.name);
  formData.append("description", dishData.description || "");
  formData.append("price", dishData.price.toString());

  // Append files
  files.forEach((file) => {
    formData.append(`gallery[]`, file);
  });
  const response = await API.post(
    `${API_ENDPOINTS.DISHES_ENDPOINT}`,
    formData,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    }
  );
  return response.data;
};

export const deleteDish = async (id: string): Promise<void> => {
  const response = await API.delete(`${API_ENDPOINTS.DISHES_ENDPOINT}/${id}`);
  return response.data;
};

export const getDishById = async (id: string): Promise<Dish> => {
  const response = await API.get(`${API_ENDPOINTS.DISHES_ENDPOINT}/${id}`);
  return response.data;
};

export const updateDishById = async (id: string): Promise<Dish> => {
  const response = await API.patch(`${API_ENDPOINTS.DISHES_ENDPOINT}/${id}`);
  return response.data;
};

export const updateDish = async (
  id: string,
  dishData: Partial<Dish>
): Promise<Dish> => {
  const response = await API.patch(
    `${API_ENDPOINTS.DISHES_ENDPOINT}/${id}`,
    dishData
  );
  return response.data;
};

export const updateDishStatus = async (
  id: string,
  dishData: Partial<Dish>
): Promise<Dish> => {
  const response = await API.patch(
    `${API_ENDPOINTS.DISHES_ENDPOINT}/${id}/activate`,
    dishData
  );
  return response.data;
};


// src/services/disheService.ts
export const addDishImages = async (id: string, formData: FormData): Promise<Dish> => {
  const response = await API.post(`${API_ENDPOINTS.DISHES_ENDPOINT}/${id}/add-images`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
  return response.data;
};

export const deleteDishImage = async (dishId: string, mediaId: string): Promise<void> => {
  const response = await API.delete(`${API_ENDPOINTS.DISHES_ENDPOINT}/${dishId}/media/${mediaId}`);
  return response.data;
};




export const getCategoryTypes = async (locale: string = 'en') => {
  const response = await API.get(`/seller/category-types`, {
    params: { locale }
  });
  return response.data;
};

export const getCategories = async (
  page: number = 1,
  limit: number = 10,
  sortBy: string = 'nameEn',
  sortOrder: string = 'asc',
  search: string = '',
  type: string = ''
) => {  
  const response = await API.get(`/seller/categories`, {
    params: { page, limit, sortBy, sortOrder, search, type }
  });

  return response.data?.data;
};

export const getCategory = async (dishId: string) => {
    const response = await API.get(
    `/seller/categories/${dishId}`
  );
  return response.data;
}

export const addDishCategory = async (dishId: string, categoryId: string) => {
  const response = await API.post(
    `/seller/food-store/dishes/${dishId}/categories`,
    { categoryId }
  );
  return response.data;
};

export const removeDishCategory = async (dishId: string, categoryId: string) => {
  await API.delete(
    `/seller/food-store/dishes/${dishId}/categories/${categoryId}`
  );
};

export const activateDish = async (id: string): Promise<Dish> => {
  const response = await API.post(`/seller/food-store/dishes/${id}/activate`);
  return response.data;
};

export const deactivateDish = async (id: string): Promise<Dish> => {
  const response = await API.post(`/seller/food-store/dishes/${id}/deactivate`);
  return response.data;
};


export const getAllergen = async (): Promise<Allergen[]> => {
  const response = await API.get(API_ENDPOINTS.SELLER_ALLERGENS);

  return response.data;
};


export const addDishAllergen = async (dishId: string, allergenId: string, specification?: string): Promise<DishAllergen> => {
  const response = await API.post(`/${API_ENDPOINTS.SELLER_ADD_ALLERGENS}/${dishId}/allergens`, {
    allergenId,
    specification
  });
  return response.data;
};

export const removeDishAllergen = async (dishId: string, allergenId: string): Promise<void> => {
  await API.delete(`/${API_ENDPOINTS.SELLER_REMOVE_ALLERGENS}/${dishId}/allergens/${allergenId}`);
};
