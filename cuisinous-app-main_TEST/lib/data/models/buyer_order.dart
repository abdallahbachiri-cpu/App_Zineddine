import 'package:cuisinous/data/models/applied_taxes.dart';

class SmallOrder {
  final String id;
  final String cartId;
  final String buyerId;
  final String buyerFullName;
  final String storeId;
  final String storeName;
  final String orderNumber;
  final String? confirmationCode;
  final String status;
  final String paymentStatus;
  final String deliveryStatus;
  final double totalPrice;
  final double taxTotal;
  final double grossTotal;
  final AppliedTaxes appliedTaxes;
  final double? tipAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? deliveryMethod;

  SmallOrder({
    required this.id,
    required this.cartId,
    required this.buyerId,
    required this.buyerFullName,
    required this.storeId,
    required this.storeName,
    required this.orderNumber,
    this.confirmationCode,
    required this.status,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.totalPrice,
    required this.taxTotal,
    required this.grossTotal,
    required this.appliedTaxes,
    this.tipAmount,
    required this.createdAt,
    this.updatedAt,
    this.deliveryMethod,
  });

  factory SmallOrder.fromJson(Map<String, dynamic> json) => SmallOrder(
    id: json['id'] as String,
    cartId: json['cartId'] as String,
    buyerId: json['buyerId'] as String,
    buyerFullName: json['buyerFullName'] as String,
    storeId: json['storeId'] as String,
    storeName: json['storeName'] as String,
    orderNumber: json['orderNumber'] as String,
    confirmationCode:
        json['confirmationCode'] != null
            ? json['confirmationCode'] as String
            : null,
    status: json['status'] as String,
    paymentStatus: json['paymentStatus'] as String,
    deliveryStatus: json['deliveryStatus'] as String,
    totalPrice: double.parse(json['totalPrice']),
    taxTotal: double.parse(json['taxTotal']),
    grossTotal: double.parse(json['grossTotal']),
    appliedTaxes: AppliedTaxes.fromJson(
      json['appliedTaxes'] as Map<String, dynamic>,
    ),
    tipAmount:
        json['tipAmount'] != null
            ? double.parse(json['tipAmount'].toString())
            : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
    deliveryMethod:
        json['deliveryMethod'] != null
            ? json['deliveryMethod'] as String
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cartId': cartId,
    'buyerId': buyerId,
    'buyerFullName': buyerFullName,
    'storeId': storeId,
    'storeName': storeName,
    'orderNumber': orderNumber,
    'confirmationCode': confirmationCode,
    'status': status,
    'paymentStatus': paymentStatus,
    'deliveryStatus': deliveryStatus,
    'totalPrice': totalPrice.toString(),
    'taxTotal': taxTotal.toString(),
    'grossTotal': grossTotal.toString(),
    'appliedTaxes': appliedTaxes.toJson(),
    'tipAmount': tipAmount?.toString(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'deliveryMethod': deliveryMethod,
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cartId': cartId,
      'buyerId': buyerId,
      'buyerFullName': buyerFullName,
      'storeId': storeId,
      'storeName': storeName,
      'orderNumber': orderNumber,
      'confirmationCode': confirmationCode,
      'status': status,
      'paymentStatus': paymentStatus,
      'deliveryStatus': deliveryStatus,
      'totalPrice': totalPrice,
      'taxTotal': taxTotal,
      'grossTotal': grossTotal,
      'appliedTaxes': appliedTaxes.toJson(),
      'tipAmount': tipAmount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deliveryMethod': deliveryMethod,
    };
  }

  factory SmallOrder.fromMap(Map<String, dynamic> map) {
    return SmallOrder(
      id: map['id'] as String,
      cartId: map['cartId'] as String,
      buyerId: map['buyerId'] as String,
      buyerFullName: map['buyerFullName'] as String,
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String,
      orderNumber: map['orderNumber'] as String,
      confirmationCode:
          map['confirmationCode'] != null
              ? map['confirmationCode'] as String
              : null,
      status: map['status'] as String,
      paymentStatus: map['paymentStatus'] as String,
      deliveryStatus: map['deliveryStatus'] as String,
      totalPrice: double.parse(map['totalPrice']),
      taxTotal: double.parse(map['taxTotal']),
      grossTotal: double.parse(map['grossTotal']),
      appliedTaxes: AppliedTaxes.fromJson(
        map['appliedTaxes'] as Map<String, dynamic>,
      ),
      tipAmount:
          map['tipAmount'] != null
              ? double.parse(map['tipAmount'].toString())
              : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      deliveryMethod:
          map['deliveryMethod'] != null
              ? map['deliveryMethod'] as String
              : null,
    );
  }

  SmallOrder copyWith({
    String? id,
    String? cartId,
    String? buyerId,
    String? buyerFullName,
    String? storeId,
    String? storeName,
    String? orderNumber,
    String? confirmationCode,
    String? status,
    String? paymentStatus,
    String? deliveryStatus,
    double? totalPrice,
    double? taxTotal,
    double? grossTotal,
    AppliedTaxes? appliedTaxes,
    double? tipAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryMethod,
  }) {
    return SmallOrder(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      buyerId: buyerId ?? this.buyerId,
      buyerFullName: buyerFullName ?? this.buyerFullName,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      orderNumber: orderNumber ?? this.orderNumber,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      taxTotal: taxTotal ?? this.taxTotal,
      grossTotal: grossTotal ?? this.grossTotal,
      appliedTaxes: appliedTaxes ?? this.appliedTaxes,
      tipAmount: tipAmount ?? this.tipAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
    );
  }
}
