import axios from 'axios';
import  { API_ENDPOINTS }  from '../config/apiConfig';
import API from './httpClient';
export interface User {
  user: User;
  id: number;
  email: string;
  password: string;
  type: string;
  profileImageUrl: string;
}

export const loginEndpoint = API_ENDPOINTS.LOGIN;
export const logoutEndpoint = API_ENDPOINTS.LOGOUT;

export const authService = {
  
  login: async (email: string, password: string): Promise<User> => {
    try {
      const response = await axios.post(loginEndpoint, { email, password });
      
      if (response.data.accessToken) {
          localStorage.setItem('accessToken', response.data.accessToken);
          localStorage.setItem('refreshToken', response.data.refreshToken);
          localStorage.setItem('user', JSON.stringify(response.data.user)); // Save user info
      }
      
      return response.data; // Return response for further use
  } catch (error: any) {
      console.error("Login error:", error.response?.data || error.message);
      throw error;
  }
  },

  googleLogin : async (googleToken: string): Promise<User> => {
    try {
      const response = await axios.post(loginEndpoint, { googleToken });
      
      if (response.data.accessToken) {
          localStorage.setItem('accessToken', response.data.accessToken);
          localStorage.setItem('refreshToken', response.data.refreshToken);
          localStorage.setItem('user', JSON.stringify(response.data.user)); // Save user info
      }
      
      return response.data; // Return response for further use
  } catch (error: any) {
      console.error("Login error:", error.response?.data || error.message);
      throw error;
  }
  },
  // Function to get the stored token
  getToken : () => {
    return localStorage.getItem('accessToken');
  },

  getCurrentUser: (): User | null => {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
  },

  // Function to check if the user is authenticated
  isAuthenticated : () => {
    return !!authService.getToken();
  },

  logout: async (): Promise<void> => {    
    const token = localStorage.getItem('accessToken');
        if (!token) throw new Error("No token found");

    const response = await API.post(`${logoutEndpoint}`);
    if (response.status !== 200) {
        throw new Error("Logout failed");
    }    
    localStorage.removeItem('user');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  },
};
