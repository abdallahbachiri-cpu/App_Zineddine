import 'package:cuisinous/data/models/order_ingredient.dart';

class BuyerOrderItem {
  final String id;
  final String dishId;
  final String dishName;
  final int quantity;
  final double price;
  final List<OrderIngredient> ingredients;

  BuyerOrderItem({
    required this.id,
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.price,
    required this.ingredients,
  });

  factory BuyerOrderItem.fromMap(Map<String, dynamic> map) => BuyerOrderItem(
    id: map['id'],
    dishId: map['dishId'],
    dishName: map['dishName'],
    quantity: map['quantity'],
    price: double.parse(map['price']),
    ingredients: List<OrderIngredient>.from(
      (map['ingredients'] as List).map((x) => OrderIngredient.fromMap(x)),
    ),
  );
}
