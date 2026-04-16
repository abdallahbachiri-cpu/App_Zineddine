import 'dart:convert';

class Rating {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String dishId;
  final String dishName;
  final String buyerId;
  final String buyerName;
  final String orderId;

  Rating({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    required this.dishId,
    required this.dishName,
    required this.buyerId,
    required this.buyerName,
    required this.orderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dishId': dishId,
      'dishName': dishName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'orderId': orderId,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String,
      rating:
          map['rating'] is int
              ? map['rating']
              : int.tryParse(map['rating'].toString()) ?? 0,
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      dishId: map['dishId'] as String,
      dishName: map['dishName'] as String,
      buyerId: map['buyerId'] as String,
      buyerName: map['buyerName'] as String,
      orderId: map['orderId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));

  Rating copyWith({
    String? id,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dishId,
    String? dishName,
    String? buyerId,
    String? buyerName,
    String? orderId,
  }) {
    return Rating(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      orderId: orderId ?? this.orderId,
    );
  }
}
