
interface TaxRate {
  rate: string;
  amount: string;
}

interface TaxRates {
  TPS: string;
  TVQ: string;
}

interface TaxAmounts {
  TPS: TaxRate;
  TVQ: TaxRate;
}

export interface Order {
  id: string;
  cartId: string;
  buyerId: string;
  buyerFullName: string;
  storeId: string;
  storeName: string;
  orderNumber: string;
  confirmationCode: string;
  status: string;
  paymentStatus: string;
  deliveryStatus: string;
  totalPrice: number;
  grossTotal: number;
  appliedTaxes: {
    rates: TaxRates;
    amounts: TaxAmounts;
  };
  createdAt: string;
  updatedAt: string | null;
}
