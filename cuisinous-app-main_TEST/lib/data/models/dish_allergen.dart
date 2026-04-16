import 'dart:convert';

class DishAllergen {
  final String id;
  final String? specification;
  final String dishId;
  final String allergenId;
  final String allergenNameFr;
  final String allergenNameEn;

  DishAllergen({
    required this.id,
    this.specification,
    required this.dishId,
    required this.allergenId,
    required this.allergenNameFr,
    required this.allergenNameEn,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'specification': specification,
      'dishId': dishId,
      'allergenId': allergenId,
      'allergenNameFr': allergenNameFr,
      'allergenNameEn': allergenNameEn,
    };
  }

  factory DishAllergen.fromMap(Map<String, dynamic> map) {
    return DishAllergen(
      id: map['id'] as String,
      specification:
          map['specification'] != null ? map['specification'] as String : null,
      dishId: map['dishId'] as String,
      allergenId: map['allergenId'] as String,
      allergenNameFr: map['allergenNameFr'] as String,
      allergenNameEn: map['allergenNameEn'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DishAllergen.fromJson(String source) =>
      DishAllergen.fromMap(json.decode(source) as Map<String, dynamic>);
}
