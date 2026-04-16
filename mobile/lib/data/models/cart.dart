import 'package:cuisinous/data/models/applied_taxes.dart';
import 'package:cuisinous/data/models/cart_dish.dart';

class Cart {
  final String id;
  final double totalPrice;
  final double? taxTotal;
  final double? grossTotal;
  final AppliedTaxes? appliedTaxes;
  final List<CartDish> dishes;

  Cart({
    required this.id,
    required this.totalPrice,
    this.taxTotal,
    this.grossTotal,
    this.appliedTaxes,
    required this.dishes,
  });

  factory Cart.fromMap(Map<String, dynamic> map) => Cart(
    id: map['id'],
    totalPrice: double.parse(map['totalPrice']),
    taxTotal: map['taxTotal'] != null ? double.parse(map['taxTotal']) : null,
    grossTotal:
        map['grossTotal'] != null ? double.parse(map['grossTotal']) : null,
    appliedTaxes:
        map['appliedTaxes'] != null
            ? AppliedTaxes.fromJson(map['appliedTaxes'] as Map<String, dynamic>)
            : null,
    dishes: List<CartDish>.from(
      (map['dishes'] as List).map((x) => CartDish.fromMap(x)),
    ),
  );

  Cart copyWith({
    String? id,
    double? totalPrice,
    double? taxTotal,
    double? grossTotal,
    AppliedTaxes? appliedTaxes,
    List<CartDish>? dishes,
  }) {
    return Cart(
      id: id ?? this.id,
      totalPrice: totalPrice ?? this.totalPrice,
      taxTotal: taxTotal ?? this.taxTotal,
      grossTotal: grossTotal ?? this.grossTotal,
      appliedTaxes: appliedTaxes ?? this.appliedTaxes,
      dishes: dishes ?? this.dishes,
    );
  }
}
