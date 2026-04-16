import API from './httpClient';
import { API_ENDPOINTS } from '../config/apiConfig';
import { 
  WalletDTO, 
  TransactionDTO,
  FoodStoreOption
} from '../types/wallet';

export const walletService = {

  async fetchFoodStores(): Promise<FoodStoreOption[]> {
    try {
      const response = await API.get(API_ENDPOINTS.ADMIN.FOOD_STORES);
      if (!response) throw new Error('Failed to fetch stores'); 
      
      const data = await response.data.data;
      
      return data.map((store: { id: string; name: string }) => ({
        value: store.id,
        label: store.name,
      }));
    } catch {
      throw new Error('Failed to fetch food stores');
    }
  },


  async fetchWallet(storeId: string): Promise<WalletDTO> {
    if (!storeId) throw new Error('Store ID is required');
    
    try {
      const response = await API.get(API_ENDPOINTS.ADMIN.WALLET(storeId));
      if (!response) throw new Error('Failed to fetch wallet');
      
      return await response.data;
    } catch {
      throw new Error('Failed to fetch wallet data');
    }
  },

  async fetchTransactions(
    storeId: string, 
    dateRange?: [string, string]
  ): Promise<TransactionDTO[]> {
    if (!storeId) throw new Error('Store ID is required');
    
    try {
      let url = API_ENDPOINTS.ADMIN.WALLET_TRANSACTIONS(storeId);
      if (dateRange) {
        url += `?startDate=${dateRange[0]}&endDate=${dateRange[1]}`;
      }
      
      const response = await API.get(url);
      if (!response) throw new Error('Failed to fetch transactions');
      
      return await response.data;
    } catch {
      throw new Error('Failed to fetch transactions');
    }
  },


  async refreshStoreData(
    storeId: string, 
    dateRange?: [string, string]
  ): Promise<{ wallet: WalletDTO; transactions: TransactionDTO[] }> {
    if (!storeId) throw new Error('Store ID is required');
    
    try {
      const [wallet, transactions] = await Promise.all([
        this.fetchWallet(storeId),
        this.fetchTransactions(storeId, dateRange)
      ]);
      
      return { wallet, transactions };
    } catch {
      throw new Error('Failed to refresh store data');
    }
  }
};

export default walletService;