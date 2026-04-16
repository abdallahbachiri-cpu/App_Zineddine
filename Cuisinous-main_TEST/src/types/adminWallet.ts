// Resources/Private/TypeScript/Admin/Wallet/types.ts
export interface WalletDTO {
  availableBalance: string | undefined;
  id: string;
  balance: number;
  currency: string;
  foodStoreId: string;
  foodStoreName: string;
  isActive?: boolean;
}

export interface TransactionDTO {
  id: string;
  amount: number;
  type: 'withdrawal' | 'order_income';
  description: string;
  createdAt: string;
  status: 'completed' | 'pending' | 'failed';
}

export interface FoodStoreOption {
  value: string;
  label: string;
}