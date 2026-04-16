import 'package:cuisinous/data/models/applied_taxes.dart';
import 'package:cuisinous/data/models/dish_ingredient.dart';

class FullOrder {
  final String id;
  final String cartId;
  final Buyer buyer;
  final Store store;
  final Location location;
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
  final String? buyerNote;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderDish> dishes;
  final String? deliveryMethod;

  FullOrder({
    required this.id,
    required this.cartId,
    required this.buyer,
    required this.store,
    required this.location,
    required this.orderNumber,
    this.confirmationCode,
    this.buyerNote,
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
    required this.dishes,
    this.deliveryMethod,
  });

  factory FullOrder.fromJson(Map<String, dynamic> json) => FullOrder(
    id: json['id'] as String,
    cartId: json['cartId'] as String,
    buyer: Buyer.fromJson(json['buyer'] as Map<String, dynamic>),
    store: Store.fromJson(json['store'] as Map<String, dynamic>),
    location: Location.fromJson(json['location'] as Map<String, dynamic>),
    orderNumber: json['orderNumber'] as String,
    confirmationCode:
        json['confirmationCode'] != null
            ? json['confirmationCode'] as String
            : null,
    buyerNote: json['buyerNote'] != null ? json['buyerNote'] as String : null,
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
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    dishes:
        (json['dishes'] as List<dynamic>)
            .map((d) => OrderDish.fromJson(d as Map<String, dynamic>))
            .toList(),
    deliveryMethod:
        json['deliveryMethod'] != null
            ? json['deliveryMethod'] as String
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cartId': cartId,
    'buyer': buyer.toJson(),
    'store': store.toJson(),
    'location': location.toJson(),
    'orderNumber': orderNumber,
    'confirmationCode': confirmationCode,
    'status': status,
    'buyerNote': buyerNote,
    'paymentStatus': paymentStatus,
    'deliveryStatus': deliveryStatus,
    'totalPrice': totalPrice.toString(),
    'taxTotal': taxTotal.toString(),
    'grossTotal': grossTotal.toString(),
    'appliedTaxes': appliedTaxes.toJson(),
    'tipAmount': tipAmount?.toString(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'dishes': dishes.map((d) => d.toJson()).toList(),
    'deliveryMethod': deliveryMethod,
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'cartId': cartId,
      'buyer': buyer.toMap(),
      'store': store.toMap(),
      'location': location.toMap(),
      'orderNumber': orderNumber,
      'confirmationCode': confirmationCode,
      'status': status,
      'buyerNote': buyerNote,
      'paymentStatus': paymentStatus,
      'deliveryStatus': deliveryStatus,
      'totalPrice': totalPrice,
      'taxTotal': taxTotal,
      'grossTotal': grossTotal,
      'appliedTaxes': appliedTaxes.toJson(),
      'tipAmount': tipAmount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'dishes': dishes.map((x) => x.toMap()).toList(),
      'deliveryMethod': deliveryMethod,
    };
  }

  factory FullOrder.fromMap(Map<String, dynamic> map) {
    return FullOrder(
      id: map['id'] as String,
      cartId: map['cartId'] as String,
      buyer: Buyer.fromMap(map['buyer'] as Map<String, dynamic>),
      store: Store.fromJson(map['store'] as Map<String, dynamic>),
      location: Location.fromMap(map['location'] as Map<String, dynamic>),
      orderNumber: map['orderNumber'] as String,
      confirmationCode:
          map['confirmationCode'] != null
              ? map['confirmationCode'] as String
              : null,
      buyerNote: map['buyerNote'] != null ? map['buyerNote'] as String : null,
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
      dishes: List<OrderDish>.from(
        (map['dishes'] as List).map<OrderDish>(
          (x) => OrderDish.fromMap(x as Map<String, dynamic>),
        ),
      ),
      deliveryMethod:
          map['deliveryMethod'] != null
              ? map['deliveryMethod'] as String
              : null,
    );
  }

  FullOrder copyWith({
    String? id,
    String? cartId,
    Buyer? buyer,
    Store? store,
    Location? location,
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
    String? buyerNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderDish>? dishes,
    String? deliveryMethod,
  }) {
    return FullOrder(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      buyer: buyer ?? this.buyer,
      store: store ?? this.store,
      location: location ?? this.location,
      orderNumber: orderNumber ?? this.orderNumber,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      status: status ?? this.status,
      buyerNote: buyerNote ?? this.buyerNote,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      taxTotal: taxTotal ?? this.taxTotal,
      grossTotal: grossTotal ?? this.grossTotal,
      appliedTaxes: appliedTaxes ?? this.appliedTaxes,
      tipAmount: tipAmount ?? this.tipAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dishes: dishes ?? this.dishes,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
    );
  }
}

class Buyer {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final String type;
  final String? phoneNumber;
  final bool isActive;
  final bool isPhoneConfirmed;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String fullName;
  final String status;
  final UserAddress? defaultAddress;

  Buyer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    required this.type,
    this.phoneNumber,
    required this.isActive,
    required this.isPhoneConfirmed,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.fullName,
    required this.status,
    this.defaultAddress,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    middleName: json['middleName'] as String?,
    email: json['email'] as String,
    type: json['type'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    isActive: json['isActive'] as bool,
    isPhoneConfirmed: json['isPhoneConfirmed'] as bool,
    isDeleted: json['isDeleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
    deletedAt:
        json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
    fullName: json['fullName'] as String,
    status: json['status'] as String,
    defaultAddress:
        json['defaultAddress'] != null
            ? UserAddress.fromJson(
              json['defaultAddress'] as Map<String, dynamic>,
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'middleName': middleName,
    'email': email,
    'type': type,
    'phoneNumber': phoneNumber,
    'isActive': isActive,
    'isPhoneConfirmed': isPhoneConfirmed,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
    'fullName': fullName,
    'status': status,
    'defaultAddress': defaultAddress?.toJson(),
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'email': email,
      'type': type,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'isPhoneConfirmed': isPhoneConfirmed,
      'isDeleted': isDeleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'deletedAt': deletedAt?.millisecondsSinceEpoch,
      'fullName': fullName,
      'status': status,
      'defaultAddress': defaultAddress?.toMap(),
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      id: map['id'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      middleName:
          map['middleName'] != null ? map['middleName'] as String : null,
      email: map['email'] as String,
      type: map['type'] as String,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      isActive: map['isActive'] as bool,
      isPhoneConfirmed: map['isPhoneConfirmed'] as bool,
      isDeleted: map['isDeleted'] as bool,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      fullName: map['fullName'] as String,
      status: map['status'] as String,
      defaultAddress:
          map['defaultAddress'] != null
              ? UserAddress.fromMap(
                map['defaultAddress'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

class UserAddress {
  final String id;
  final double latitude;
  final double longitude;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String additionalDetails;

  UserAddress({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.additionalDetails,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    id: json['id'] as String,
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    street: json['street'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    zipCode: json['zipCode'] as String,
    country: json['country'] as String,
    additionalDetails: json['additionalDetails'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
    'additionalDetails': additionalDetails,
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
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

  factory UserAddress.fromMap(Map<String, dynamic> map) {
    return UserAddress(
      id: map['id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      street: map['street'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      zipCode: map['zipCode'] as String,
      country: map['country'] as String,
      additionalDetails: map['additionalDetails'] as String,
    );
  }
}

class Store {
  final String id;
  final String name;
  final String sellerId;
  String? description;
  final StoreAddress address;
  final DateTime createdAt;
  DateTime? updatedAt;
  String? profileImageUrl;

  Store({
    required this.id,
    required this.name,
    required this.sellerId,
    this.description,
    required this.address,
    required this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json['id'] as String,
    name: json['name'] as String,
    sellerId: json['sellerId'] as String,
    description: json['description'] as String?,
    address: StoreAddress.fromJson(json['address'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    profileImageUrl: json['profileImageUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sellerId': sellerId,
    'description': description,
    'address': address.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'profileImageUrl': profileImageUrl,
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'sellerId': sellerId,
      'description': description,
      'address': address.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] as String,
      name: map['name'] as String,
      sellerId: map['sellerId'] as String,
      description: map['description'] as String?,
      address: StoreAddress.fromMap(map['address'] as Map<String, dynamic>),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }
}

class StoreAddress {
  final String id;
  final double latitude;
  final double longitude;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? additionalDetails;

  StoreAddress({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.additionalDetails,
  });

  factory StoreAddress.fromJson(Map<String, dynamic> json) => StoreAddress(
    id: json['id'] as String,
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    street: json['street'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    zipCode: json['zipCode'] as String?,
    country: json['country'] as String?,
    additionalDetails: json['additionalDetails'] as String?,
  );

  Map<String, dynamic> toJson() =>
      StoreAddress(
        id: id,
        latitude: latitude,
        longitude: longitude,
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        country: country,
        additionalDetails: additionalDetails,
      ).toJson();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
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

  factory StoreAddress.fromMap(Map<String, dynamic> map) {
    return StoreAddress(
      id: map['id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      street: map['street'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      zipCode: map['zipCode'] as String?,
      country: map['country'] as String?,
      additionalDetails: map['additionalDetails'] as String?,
    );
  }
}

class Location {
  final String id;
  final double latitude;
  final double longitude;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String additionalDetails;

  Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.additionalDetails,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json['id'] as String,
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    street: json['street'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    zipCode: json['zipCode'] as String,
    country: json['country'] as String,
    additionalDetails: json['additionalDetails'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
    'additionalDetails': additionalDetails,
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
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

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      street: map['street'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      zipCode: map['zipCode'] as String,
      country: map['country'] as String,
      additionalDetails: map['additionalDetails'] as String,
    );
  }
}

class OrderDish {
  final String id;
  final String orderId;
  final Dish dish;
  final List<OrderIngredient> ingredients;
  final double unitPrice;
  final double baseSubtotalPrice;
  final double totalPrice;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderDish({
    required this.id,
    required this.orderId,
    required this.dish,
    required this.ingredients,
    required this.unitPrice,
    required this.baseSubtotalPrice,
    required this.totalPrice,
    required this.quantity,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderDish.fromJson(Map<String, dynamic> json) => OrderDish(
    id: json['id'] as String,
    orderId: json['orderId'] as String,
    dish: Dish.fromJson(json['dish'] as Map<String, dynamic>),
    ingredients:
        (json['ingredients'] as List<dynamic>)
            .map((i) => OrderIngredient.fromJson(i as Map<String, dynamic>))
            .toList(),
    unitPrice: double.parse(json['unitPrice']),
    baseSubtotalPrice: double.parse(json['baseSubtotalPrice']),
    totalPrice: double.parse(json['totalPrice']),
    quantity: json['quantity'] as int,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'dish': dish.toJson(),
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'unitPrice': unitPrice.toString(),
    'baseSubtotalPrice': baseSubtotalPrice.toString(),
    'totalPrice': totalPrice.toString(),
    'quantity': quantity,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'orderId': orderId,
      'dish': dish.toMap(),
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
      'unitPrice': unitPrice,
      'baseSubtotalPrice': baseSubtotalPrice,
      'totalPrice': totalPrice,
      'quantity': quantity,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory OrderDish.fromMap(Map<String, dynamic> map) {
    return OrderDish(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      dish: Dish.fromMap(map['dish'] as Map<String, dynamic>),
      ingredients: List<OrderIngredient>.from(
        (map['ingredients'] as List).map<OrderIngredient>(
          (x) => OrderIngredient.fromMap(x as Map<String, dynamic>),
        ),
      ),
      unitPrice: double.parse(map['unitPrice']),
      baseSubtotalPrice: double.parse(map['baseSubtotalPrice']),
      totalPrice: double.parse(map['totalPrice']),
      quantity: map['quantity'] as int,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

class Dish {
  final String id;
  final String name;
  final String? description;
  final double price;
  final bool available;
  final String foodStoreId;
  final String foodStoreName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<GalleryImage> gallery;

  Dish({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.available,
    required this.foodStoreId,
    required this.foodStoreName,
    required this.createdAt,
    this.updatedAt,
    required this.gallery,
  });

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    price: double.parse(json['price']),
    available: json['available'] as bool,
    foodStoreId: json['foodStoreId'] as String,
    foodStoreName: json['foodStoreName'] as String,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    gallery:
        (json['gallery'] as List<dynamic>)
            .map((g) => GalleryImage.fromJson(g as Map<String, dynamic>))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price.toString(),
    'available': available,
    'foodStoreId': foodStoreId,
    'foodStoreName': foodStoreName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'gallery': gallery.map((g) => g.toJson()).toList(),
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'available': available,
      'foodStoreId': foodStoreId,
      'foodStoreName': foodStoreName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'gallery': gallery.map((x) => x.toMap()).toList(),
    };
  }

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: double.parse(map['price']),
      available: map['available'] as bool,
      foodStoreId: map['foodStoreId'] as String,
      foodStoreName: map['foodStoreName'] as String,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      gallery: List<GalleryImage>.from(
        (map['gallery'] as List).map<GalleryImage>(
          (x) => GalleryImage.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class GalleryImage {
  final String id;
  final String originalName;
  final String url;
  final String fileType;

  GalleryImage({
    required this.id,
    required this.originalName,
    required this.url,
    required this.fileType,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) => GalleryImage(
    id: json['id'] as String,
    originalName: json['originalName'] as String,
    url: json['url'] as String,
    fileType: json['fileType'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalName': originalName,
    'url': url,
    'fileType': fileType,
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'originalName': originalName,
      'url': url,
      'fileType': fileType,
    };
  }

  factory GalleryImage.fromMap(Map<String, dynamic> map) {
    return GalleryImage(
      id: map['id'] as String,
      originalName: map['originalName'] as String,
      url: map['url'] as String,
      fileType: map['fileType'] as String,
    );
  }
}

class OrderIngredient {
  final String id;
  final String orderDishId;
  final DishIngredient dishIngredient;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderIngredient({
    required this.id,
    required this.orderDishId,
    required this.dishIngredient,
    required this.price,
    required this.quantity,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderIngredient.fromJson(Map<String, dynamic> json) =>
      OrderIngredient(
        id: json['id'] as String,
        orderDishId: json['orderDishId'] as String,
        dishIngredient: DishIngredient.fromMap(
          json['dishIngredient'] as Map<String, dynamic>,
        ),
        price: double.parse(json['price']),
        quantity: json['quantity'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderDishId': orderDishId,
    'dishIngredient': dishIngredient.toJson(),
    'price': price,
    'quantity': quantity,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'orderDishId': orderDishId,
      'dishIngredient': dishIngredient.toMap(),
      'price': price,
      'quantity': quantity,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory OrderIngredient.fromMap(Map<String, dynamic> map) {
    return OrderIngredient(
      id: map['id'] as String,
      orderDishId: map['orderDishId'] as String,
      dishIngredient: DishIngredient.fromMap(
        map['dishIngredient'] as Map<String, dynamic>,
      ),
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'] as String)
              : null,
    );
  }
}
