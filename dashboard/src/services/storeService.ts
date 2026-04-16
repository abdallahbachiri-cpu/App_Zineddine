import API from './httpClient';
export const createFoodStore = async (storeData: FormData) => {
  const response = await API.post("/seller/food-store", storeData, {
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
  return response.data;
};

export const getFoodStore = async () => {
  const response = await API.get("/seller/food-store");
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
