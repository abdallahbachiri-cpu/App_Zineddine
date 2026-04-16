import 'package:cuisinous/data/models/picked_location.dart';

class Address extends PickedLocation {
  Address({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.street,
    required super.city,
    required super.state,
    required super.zipCode,
    required super.country,
    required super.additionalDetails,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'],
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    street: json['street'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'],
    country: json['country'],
    additionalDetails: json['additionalDetails'],
  );
}
