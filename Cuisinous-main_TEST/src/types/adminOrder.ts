export interface AdminOrderResponse {
  data: AdminOrder[];
}

export interface AdminOrder {
  id: string;
  cartId: string;
  buyer: {
    fullName: string;
    id: string;
  }
  storeId: string;
  store: {
    name:string;
    id:string;
  }
  orderNumber: string;
  confirmationCode: string;
  status: string;
  paymentStatus: string;
  deliveryStatus: string;
  totalPrice: string;
  createdAt: string;
  updatedAt: string | null;
}
