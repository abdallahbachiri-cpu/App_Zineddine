class SellerOrderItem {
  final String id;
  final String dishId;
  final String dishName;
  final int quantity;
  final double price;

  SellerOrderItem({
    required this.id,
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.price,
  });

  factory SellerOrderItem.fromMap(Map<String, dynamic> map) => SellerOrderItem(
    id: map['id'],
    dishId: map['dishId'],
    dishName: map['dishName'],
    quantity: map['quantity'],
    price: (map['price'] as num).toDouble(),
  );
}
