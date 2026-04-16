import API from './httpClient';
import { API_ENDPOINTS } from '../config/apiConfig';
import { Ingredient, DishIngredient } from '../types/menu';

// Get all available ingredients for the food store
export const getAllIngredients = async (): Promise<{ data: Ingredient[] }> => {
  const response = await API.get(API_ENDPOINTS.FOOD_STORE_INGREDIENTS);
  return response.data;
};

// Create a new ingredient for the food store
export const createIngredient = async (data: {
  nameFr: string;
  nameEn: string;
}): Promise<Ingredient> => {
  const response = await API.post(API_ENDPOINTS.FOOD_STORE_INGREDIENTS, data);
  return response.data;
};

// Get an ingredient by ID
export const getIngredientById = async (id: string): Promise<Ingredient> => {
  const response = await API.get(`${API_ENDPOINTS.FOOD_STORE_INGREDIENTS}/${id}`);
  return response.data;
};

// Update an ingredient
export const updateIngredient = async (
  id: string,
  data: Partial<{
    nameFr: string;
    nameEn: string;
  }>
): Promise<Ingredient> => {
  const response = await API.patch(
    `${API_ENDPOINTS.FOOD_STORE_INGREDIENTS}/${id}`,
    data
  );
  return response.data;
};

// Delete an ingredient
export const deleteIngredient = async (id: string): Promise<void> => {
  await API.delete(`${API_ENDPOINTS.FOOD_STORE_INGREDIENTS}/${id}`);
};

// Get ingredients for a specific dish
export const getDishIngredients = async (dishId: string): Promise<DishIngredient[]> => {
  const response = await API.get(`${API_ENDPOINTS.DISHES_ENDPOINT}/${dishId}/ingredients`);
  return response.data;
};

// Add an ingredient to a dish
export const addDishIngredient = async (
  dishId: string,
  ingredientId: string,
  data: { isSupplement: boolean; price: number }
): Promise<DishIngredient> => {
  const response = await API.post(
    `${API_ENDPOINTS.DISHES_ENDPOINT}/${dishId}/ingredients`,
    { ingredientId, ...data }
  );
  return response.data;
};

// Update a dish ingredient
export const updateDishIngredient = async (
  dishId: string,
  ingredientId: string,
  data: Partial<{
    price: number;
    isSupplement: boolean;
    available: boolean;
  }>
): Promise<DishIngredient> => {
  const response = await API.patch(
    `${API_ENDPOINTS.DISHES_ENDPOINT}/${dishId}/ingredients/${ingredientId}`,
    data
  );
  return response.data;
};

// Remove an ingredient from a dish
export const removeDishIngredient = async (
  dishId: string,
  ingredientId: string
): Promise<void> => {
  await API.delete(
    `${API_ENDPOINTS.DISHES_ENDPOINT}/${dishId}/ingredients/${ingredientId}`
  );
};