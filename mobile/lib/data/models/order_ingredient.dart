class OrderIngredient {
  final String id;
  final String name;
  final double price;
  final int quantity;

  OrderIngredient({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderIngredient.fromMap(Map<String, dynamic> map) => OrderIngredient(
    id: map['id'],
    name: map['name'],
    price: double.parse(map['price']),
    quantity: map['quantity'],
  );
}
