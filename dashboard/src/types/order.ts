
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

// Admin order types (merged from adminOrder.ts)
export interface AdminOrderResponse {
  data: AdminOrder[];
}

export interface AdminOrder {
  id: string;
  cartId: string;
  buyer: {
    fullName: string;
    id: string;
  };
  storeId: string;
  store: {
    name: string;
    id: string;
  };
  orderNumber: string;
  confirmationCode: string;
  status: string;
  paymentStatus: string;
  deliveryStatus: string;
  totalPrice: string;
  createdAt: string;
  updatedAt: string | null;
}
