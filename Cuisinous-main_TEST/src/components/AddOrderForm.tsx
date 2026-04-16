import React, { useState } from 'react';
import { ordersMockData } from '../mockData/orders';

// interface OrderItem {
//   productId: string;
//   name: string;
//   quantity: number;
//   price: number;
// }

const AddOrderForm: React.FC = () => {
  const [order, setOrder] = useState({
    userId: '',
    status: '',
    totalAmount: 0,
    items: [{ productId: '', name: '', quantity: 0, price: 0 }],
  });
  
  // Handle form field changes
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>, field: string, index?: number) => {
    const value = e.target.value;
    
    if (index !== undefined) {
      // Update item details in the items array
      const updatedItems = [...order.items];
      updatedItems[index] = { ...updatedItems[index], [field]: value };
      setOrder((prevState) => ({ ...prevState, items: updatedItems }));
    } else {
      // Update order details
      setOrder((prevState) => ({ ...prevState, [field]: value }));
    }
  };

  // Add new order item row
  const addItemRow = () => {
    setOrder((prevState) => ({
      ...prevState,
      items: [...prevState.items, { productId: '', name: '', quantity: 0, price: 0 }],
    }));
  };

  // Handle form submission
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const newOrder = { ...order, orderId: `${ordersMockData.length + 1}`, createdAt: new Date().toISOString() };

    // Add the new order to mock data
    ordersMockData.push(newOrder);

    // Reset form state
    setOrder({
      userId: '',
      status: '',
      totalAmount: 0,
      items: [{ productId: '', name: '', quantity: 0, price: 0 }],
    });

    alert('Order added successfully!');
  };

  return (
    <form onSubmit={handleSubmit}>
      <h3>Add New Order</h3>
      
      {/* User ID */}
      <div>
        <label>User ID</label>
        <input
          type="text"
          value={order.userId}
          onChange={(e) => handleChange(e, 'userId')}
          placeholder="Enter user ID"
        />
      </div>

      {/* Order Status */}
      <div>
        <label>Status</label>
        <input
          type="text"
          value={order.status}
          onChange={(e) => handleChange(e, 'status')}
          placeholder="Enter order status"
        />
      </div>

      {/* Order Items */}
      <div>
        <h4>Order Items</h4>
        {order.items.map((item, index) => (
          <div key={index}>
            <label>Product ID</label>
            <input
              type="text"
              value={item.productId}
              onChange={(e) => handleChange(e, 'productId', index)}
              placeholder="Enter product ID"
            />
            
            <label>Product Name</label>
            <input
              type="text"
              value={item.name}
              onChange={(e) => handleChange(e, 'name', index)}
              placeholder="Enter product name"
            />
            
            <label>Quantity</label>
            <input
              type="number"
              value={item.quantity}
              onChange={(e) => handleChange(e, 'quantity', index)}
              placeholder="Enter quantity"
            />
            
            <label>Price</label>
            <input
              type="number"
              value={item.price}
              onChange={(e) => handleChange(e, 'price', index)}
              placeholder="Enter price"
            />
          </div>
        ))}
        
        {/* Button to add new item row */}
        <button type="button" onClick={addItemRow}>
          Add Item
        </button>
      </div>

      {/* Total Amount */}
      <div>
        <label>Total Amount</label>
        <input
          type="number"
          value={order.totalAmount}
          onChange={(e) => handleChange(e, 'totalAmount')}
          placeholder="Enter total amount"
        />
      </div>

      {/* Submit Button */}
      <button type="submit">Add Order</button>
    </form>
  );
};

export default AddOrderForm;
