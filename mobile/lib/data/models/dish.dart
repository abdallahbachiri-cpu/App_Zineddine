import 'dart:convert';
import 'package:cuisinous/data/models/address.dart';
import 'package:cuisinous/data/models/category.dart';
import 'package:cuisinous/data/models/dish_ingredient.dart';
import 'package:cuisinous/data/models/media.dart';
import 'package:cuisinous/data/models/dish_allergen.dart';

class Dish {
  final String id;
  final String name;
  final String foodStoreId;
  final String foodStoreName;
  final String? foodStoreProfileImageUrl;
  final Address? foodStoreAddress;
  final String? description;
  final double price;
  final bool available;
  final double averageRating;

  final List<Media> gallery;
  final List<DishIngredient>? ingredients;
  final List<Category>? categories;
  final List<DishAllergen>? allergens;

  Dish({
    required this.id,
    required this.name,
    required this.foodStoreId,
    required this.foodStoreName,
    this.description,
    this.foodStoreProfileImageUrl,
    this.foodStoreAddress,
    required this.price,
    required this.available,
    required this.gallery,
    this.ingredients,
    this.categories,
    this.allergens,
    required this.averageRating,
  });

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'] as String,
      name: map['name'] as String,
      foodStoreId: map['foodStoreId'] as String,
      foodStoreName: map['foodStoreName'] as String,
      foodStoreProfileImageUrl:
          map['foodStoreProfileImageUrl'] != null
              ? map['foodStoreProfileImageUrl'] as String
              : null,
      foodStoreAddress:
          map['foodStoreAddress'] != null
              ? Address.fromJson(
                map['foodStoreAddress'] as Map<String, dynamic>,
              )
              : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      price: double.parse(map['price']),
      available: map['available'] as bool,
      gallery: List<Media>.from(
        (map['gallery'] as List).map<Media>(
          (x) => Media.fromMap(x as Map<String, dynamic>),
        ),
      ),
      ingredients:
          map['ingredients'] != null
              ? List<DishIngredient>.from(
                (map['ingredients'] as List).map<DishIngredient?>(
                  (x) => DishIngredient.fromMap(x as Map<String, dynamic>),
                ),
              )
              : null,
      categories:
          map['categories'] != null
              ? List<Category>.from(
                (map['categories'] as List).map<Category?>(
                  (x) => Category.fromMap(x as Map<String, dynamic>),
                ),
              )
              : null,
      allergens:
          map['allergens'] != null
              ? List<DishAllergen>.from(
                (map['allergens'] as List).map<DishAllergen?>(
                  (x) => DishAllergen.fromMap(x as Map<String, dynamic>),
                ),
              )
              : null,
      averageRating: double.parse(map['averageRating'].toString()),
    );
  }
  Dish copyWith({
    String? id,
    String? name,
    String? foodStoreId,
    String? foodStoreName,
    String? foodStoreProfileImageUrl,
    Address? foodStoreAddress,
    String? description,
    double? price,
    bool? available,
    double? averageRating,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Media>? gallery,
    List<DishIngredient>? ingredients,
    List<Category>? categories,
    List<DishAllergen>? allergens,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      foodStoreId: foodStoreId ?? this.foodStoreId,
      foodStoreName: foodStoreName ?? this.foodStoreName,
      foodStoreProfileImageUrl:
          foodStoreProfileImageUrl ?? this.foodStoreProfileImageUrl,
      foodStoreAddress: foodStoreAddress ?? this.foodStoreAddress,
      description: description ?? this.description,
      price: price ?? this.price,
      available: available ?? this.available,
      gallery: gallery ?? this.gallery,
      ingredients: ingredients ?? this.ingredients,
      categories: categories ?? this.categories,
      allergens: allergens ?? this.allergens,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'foodStoreId': foodStoreId,
      'foodStoreName': foodStoreName,
      'foodStoreProfileImageUrl': foodStoreProfileImageUrl,
      'foodStoreAddress': foodStoreAddress?.toMap(),
      'description': description,
      'price': price,
      'available': available,
      'gallery': gallery.map((x) => x.toMap()).toList(),
      'ingredients': ingredients?.map((x) => x.toMap()).toList(),
      'categories': categories?.map((x) => x.toMap()).toList(),
      'allergens': allergens?.map((x) => x.toMap()).toList(),
      'averageRating': averageRating,
    };
  }

  String toJson() => json.encode(toMap());

  factory Dish.fromJson(String source) =>
      Dish.fromMap(json.decode(source) as Map<String, dynamic>);
}
