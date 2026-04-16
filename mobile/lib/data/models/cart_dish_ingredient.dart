import 'dart:convert';

import 'package:cuisinous/data/models/dish_ingredient.dart';

class CartDishIngredient {
  final String id;
  final DishIngredient ingredient;
  final int quantity;

  CartDishIngredient({
    required this.id,
    required this.ingredient,
    required this.quantity,
  });

  factory CartDishIngredient.fromMap(Map<String, dynamic> map) {
    return CartDishIngredient(
      id: map['id'] as String,
      ingredient: DishIngredient.fromMap(
        map['ingredient'] as Map<String, dynamic>,
      ),
      quantity: map['quantity'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ingredient': ingredient.toMap(),
      'quantity': quantity,
    };
  }

  String toJson() => json.encode(toMap());

  factory CartDishIngredient.fromJson(String source) =>
      CartDishIngredient.fromMap(json.decode(source) as Map<String, dynamic>);

  CartDishIngredient copyWith({
    String? id,
    DishIngredient? ingredient,
    int? quantity,
  }) {
    return CartDishIngredient(
      id: id ?? this.id,
      ingredient: ingredient ?? this.ingredient,
      quantity: quantity ?? this.quantity,
    );
  }
}
