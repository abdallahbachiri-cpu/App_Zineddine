import 'package:cuisinous/data/models/address.dart';

class FoodStore {
  final String id;
  final String name;
  final String? description;
  final String sellerId;
  final Address? address;
  final String? profileImageUrl;
  final bool isStripeConnected;
  final String deliveryOption;
  final bool vendorAgreementAccepted;

  FoodStore({
    required this.id,
    required this.name,
    this.description,
    required this.sellerId,
    this.address,
    this.profileImageUrl,
    required this.isStripeConnected,
    required this.deliveryOption,
    required this.vendorAgreementAccepted,
  });

  factory FoodStore.fromJson(Map<String, dynamic> json) => FoodStore(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    sellerId: json['sellerId'],
    address: json['address'] != null ? Address.fromJson(json['address']) : null,
    profileImageUrl: json['profileImageUrl'],
    isStripeConnected: json['isStripeConnected'],
    deliveryOption: json['deliveryOption'],
    vendorAgreementAccepted: json['vendorAgreementAccepted'],
  );
}
