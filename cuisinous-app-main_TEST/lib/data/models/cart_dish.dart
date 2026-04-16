import 'dart:convert';

import 'package:cuisinous/data/models/cart_dish_ingredient.dart';
import 'package:cuisinous/data/models/dish.dart';

class CartDish {
  final String id;
  final Dish dish;
  final int quantity;
  final List<CartDishIngredient> ingredients;
  final double dishUnitPrice;
  final double totalPrice;

  CartDish({
    required this.id,
    required this.dish,
    required this.quantity,
    required this.ingredients,
    required this.dishUnitPrice,
    required this.totalPrice,
  });

  factory CartDish.fromMap(Map<String, dynamic> map) {
    return CartDish(
      id: map['id'] as String,
      dish: Dish.fromMap(map['dish'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
      ingredients: List<CartDishIngredient>.from(
        (map['ingredients'] as List).map<CartDishIngredient>(
          (x) => CartDishIngredient.fromMap(x as Map<String, dynamic>),
        ),
      ),
      dishUnitPrice: double.parse(map['dishUnitPrice']),
      totalPrice: double.parse(map['totalPrice']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'dish': dish.toMap(),
      'quantity': quantity,
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
      'dishUnitPrice': dishUnitPrice,
      'totalPrice': totalPrice,
    };
  }

  String toJson() => json.encode(toMap());

  factory CartDish.fromJson(String source) =>
      CartDish.fromMap(json.decode(source) as Map<String, dynamic>);

  CartDish copyWith({
    String? id,
    Dish? dish,
    int? quantity,
    List<CartDishIngredient>? ingredients,
    double? dishUnitPrice,
    double? totalPrice,
  }) {
    return CartDish(
      id: id ?? this.id,
      dish: dish ?? this.dish,
      quantity: quantity ?? this.quantity,
      ingredients: ingredients ?? this.ingredients,
      dishUnitPrice: dishUnitPrice ?? this.dishUnitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
