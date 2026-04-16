import API from './httpClient';


export const getAllUsers = async (params = {}) => {
  try {
    const response = await API.get("/admin/users", { params });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch users", error);
    throw error;
  }
};



// Get a user by ID
export const getUserById = async (userId:string) => {
    try {
      const response = await API.get(`/admin/users/${userId}`);
      return response.data;
    } catch (error) {
      console.error("Failed to fetch user by ID", error);
      throw error;
    }
  };
  
  // Update a user by ID
  export const updateUser = async (userId: string, updatedData: {
    phoneNumber?: string;
    firstName?: string;
    lastName?: string;
    middleName?: string;
  }) => {
    try {
      const response = await API.patch(`/admin/users/${userId}`, updatedData);
      return response.data;
    } catch (error) {
      console.error("Failed to update user", error);
      throw error;
    }
  };
  
  // Restore a deleted user by ID
  export const restoreUser = async (userId:string) => {
    try {
      await API.post(`/admin/users/${userId}/restore`);
    } catch (error) {
      console.error("Failed to restore user", error);
      throw error;
    }
  };
  
  // Activate a suspended user by ID
  export const activateUser = async (userId:string) => {
    try {
      await API.post(`/admin/users/${userId}/activate`);
    } catch (error) {
      console.error("Failed to activate user", error);
      throw error;
    }
  };
  
  // Suspend a user by ID
  export const suspendUser = async (userId:string) => {
    try {
      await API.post(`/admin/users/${userId}/suspend`).then((response) => {
        console.log("User suspended successfully:", response.data);
      });
    } catch (error) {
      console.error("Failed to suspend user", error);
      throw error;
    }
  };