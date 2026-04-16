import 'package:cuisinous/data/models/seller_order_item.dart';
import 'package:cuisinous/core/enums/order_enums.dart';

class SellerOrder {
  final String id;
  final OrderStatus status;
  final OrderPaymentStatus paymentStatus;
  final OrderDeliveryStatus deliveryStatus;
  final double totalAmount;
  final DateTime createdAt;
  final List<SellerOrderItem> items;
  final String? buyerId;
  final String? confirmationCode;
  final String? deliveryMethod;

  SellerOrder({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
    this.buyerId,
    this.confirmationCode,
    this.deliveryMethod,
  });

  factory SellerOrder.fromMap(Map<String, dynamic> map) => SellerOrder(
    id: map['id'],
    status: OrderStatus.values.firstWhere(
      (e) => e.name == map['status'],
      orElse: () => OrderStatus.pending,
    ),
    paymentStatus: OrderPaymentStatus.values.firstWhere(
      (e) => e.name == map['paymentStatus'],
      orElse: () => OrderPaymentStatus.pending,
    ),
    deliveryStatus: OrderDeliveryStatus.values.firstWhere(
      (e) => e.name == map['deliveryStatus'],
      orElse: () => OrderDeliveryStatus.pending,
    ),
    totalAmount: (map['totalAmount'] as num).toDouble(),
    createdAt: DateTime.parse(map['createdAt']),
    items: List<SellerOrderItem>.from(
      (map['items'] as List).map((x) => SellerOrderItem.fromMap(x)),
    ),
    buyerId: map['buyerId'],
    confirmationCode: map['confirmationCode'],
    deliveryMethod: map['deliveryMethod'],
  );

  SellerOrder copyWith({
    String? id,
    OrderStatus? status,
    OrderPaymentStatus? paymentStatus,
    OrderDeliveryStatus? deliveryStatus,
    double? totalAmount,
    DateTime? createdAt,
    List<SellerOrderItem>? items,
    String? buyerId,
    String? confirmationCode,
    String? deliveryMethod,
  }) {
    return SellerOrder(
      id: id ?? this.id,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      buyerId: buyerId ?? this.buyerId,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
    );
  }
}
