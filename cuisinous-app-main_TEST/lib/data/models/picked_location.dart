import 'dart:convert';

class PickedLocation {
  final String? id;
  final double latitude;
  final double longitude;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? additionalDetails;

  PickedLocation({
    this.id,
    required this.latitude,
    required this.longitude,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.additionalDetails,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'additionalDetails': additionalDetails,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickedLocation &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  factory PickedLocation.fromMap(Map<String, dynamic> map) {
    return PickedLocation(
      id: map['id'] != null ? map['id'] as String : null,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      street: map['street'] != null ? map['street'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      state: map['state'] != null ? map['state'] as String : null,
      zipCode: map['zipCode'] != null ? map['zipCode'] as String : null,
      country: map['country'] != null ? map['country'] as String : null,
      additionalDetails:
          map['additionalDetails'] != null
              ? map['additionalDetails'] as String
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PickedLocation.fromJson(String source) =>
      PickedLocation.fromMap(json.decode(source) as Map<String, dynamic>);

  PickedLocation copyWith({
    double? latitude,
    double? longitude,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? additionalDetails,
  }) {
    return PickedLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      additionalDetails: additionalDetails ?? this.additionalDetails,
    );
  }
}
