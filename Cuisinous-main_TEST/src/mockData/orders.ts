export const ordersMockData = [
    {
      orderId: '1',
      userId: '1',
      status: 'Pending',
      totalAmount: 120.50,
      createdAt: '2024-11-15T10:30:00',
      items: [
        { productId: '101', name: 'Product 1', quantity: 2, price: 40.00 },
        { productId: '102', name: 'Product 2', quantity: 1, price: 40.50 },
      ],
    },
    {
      orderId: '2',
      userId: '2',
      status: 'Shipped',
      totalAmount: 150.00,
      createdAt: '2024-11-14T12:00:00',
      items: [
        { productId: '103', name: 'Product 3', quantity: 3, price: 50.00 },
      ],
    },
    {
      orderId: '3',
      userId: '3',
      status: 'Delivered',
      totalAmount: 200.00,
      createdAt: '2024-11-13T14:45:00',
      items: [
        { productId: '104', name: 'Product 4', quantity: 4, price: 50.00 },
      ],
    },
  ];
  