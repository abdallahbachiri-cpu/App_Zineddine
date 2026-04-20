// Use VITE_API_URL from .env (defaults to Render production if not set)
export const API_BASE_URL: string =
  (import.meta as any).env?.VITE_API_URL || 'https://cuisinous-api.onrender.com';

export const GOOGLE_CLIENT_ID = '692585298078-1tcp9trt0o51p2b5530j78gfjmcfr71v.apps.googleusercontent.com';

export const API_ENDPOINTS = {
  LOGIN: `${API_BASE_URL}/api/auth/login`,
  REFRESH_TOKEN: `${API_BASE_URL}/auth/token/refresh`,
  REGISTER: `${API_BASE_URL}/api/auth/register`,
  CALLBACK: `${API_BASE_URL}/auth/google/callback`,
  LOGOUT: `${API_BASE_URL}/api/user/logout`,
  ORDERS: `${API_BASE_URL}/orders`,

  DISHES_ENDPOINT : "/seller/food-store/dishes",
  DISHES_ENDPOINT_ACTIVATE : "/seller/food-store/dishes",
  SELLER_INGREDIENTS: "seller/ingredients",
  SELLER_ALLERGENS: "/seller/allergens",
  SELLER_ADD_ALLERGENS: "seller/food-store/dishes",
  SELLER_REMOVE_ALLERGENS: "seller/food-store/dishes",

  FOOD_STORE_INGREDIENTS: '/seller/food-store/ingredients',
  SELLER_STATISTICS: '/seller/stats',
  SELLER_REVENUE_BY_YEAR: '/seller/stats/revenue',
  SELLER_REVENUE_BY_MONTH: '/seller/stats/revenue',
  SELLER_REVENUE_BY_DAY: '/seller/stats/revenue',
    ADMIN: {
      GET_ALL_USERS: `${API_BASE_URL}/api/admin/users`,
      ADMIN_STATISTICS: '/admin/stats',
      ADMIN_REVENUE_BY_YEAR: '/admin/stats/revenue',
      ADMIN_REVENUE_BY_MONTH: '/admin/stats/revenue',
      ADMIN_REVENUE_BY_DAY: '/admin/stats/revenue',
      FOOD_STORES: '/admin/food-stores',
      WALLET: (storeId: string) => `/admin/food-stores/${storeId}/wallet`,
      WALLET_TRANSACTIONS: (storeId: string) => `/admin/food-stores/${storeId}/wallet/transactions`,
      WALLET_BLOCK: (storeId: string) => `/admin/food-stores/${storeId}/wallet/block`,
      WALLET_UNBLOCK: (storeId: string) => `/admin/food-stores/${storeId}/wallet/unblock`,
      BROADCAST_NOTIFICATIONS: '/notifications/broadcast',
    }
};

export default API_BASE_URL;
