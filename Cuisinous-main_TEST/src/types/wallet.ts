export interface WalletDTO {
  availableBalance: string | undefined;
  id: string;
  balance: number;
  currency: string;
  isActive?: boolean;
}

export interface TransactionDTO {
  id: string;
  amount: number;
  grossAmount: number;
  commissionAmount: number;
  commissionRate: number;
  type: 'withdrawal' | 'order_income';
  description: string;
  createdAt: string;
  status: 'completed' | 'pending' | 'failed';
}

export interface CardInfo {
  id?: string;
  cardNumber: string;
  firstName: string;
  lastName: string;
  expirationMonth: string;
  expirationYear: string;
  cvv: string;
  isDefault?: boolean;
}