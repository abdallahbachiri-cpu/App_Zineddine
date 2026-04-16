import 'dart:convert';

class DishIngredient {
  final String id;
  final double price;
  final bool available;
  final bool isSupplement;
  final String dishId;
  final String ingredientId;
  final String ingredientNameFr;
  final String ingredientNameEn;

  DishIngredient({
    required this.id,
    required this.price,
    required this.available,
    required this.isSupplement,
    required this.dishId,
    required this.ingredientId,
    required this.ingredientNameFr,
    required this.ingredientNameEn,
  });

  factory DishIngredient.fromMap(Map<String, dynamic> map) {
    return DishIngredient(
      id: map['id'] as String,
      price: double.parse(map['price']),
      available: map['available'] as bool,
      isSupplement: map['isSupplement'] as bool,
      dishId: map['dishId'] as String,
      ingredientId: map['ingredientId'] as String,
      ingredientNameFr: map['ingredientNameFr'] as String,
      ingredientNameEn: map['ingredientNameEn'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'price': price,
      'available': available,
      'isSupplement': isSupplement,
      'dishId': dishId,
      'ingredientId': ingredientId,
      'ingredientNameFr': ingredientNameFr,
      'ingredientNameEn': ingredientNameEn,
    };
  }

  String toJson() => json.encode(toMap());

  factory DishIngredient.fromJson(String source) =>
      DishIngredient.fromMap(json.decode(source) as Map<String, dynamic>);
}
