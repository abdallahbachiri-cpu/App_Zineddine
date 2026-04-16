import 'dart:convert';

class Allergen {
  final String id;
  final String nameFr;
  final String nameEn;
  final bool requiresSpecification;

  Allergen({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.requiresSpecification,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nameFr': nameFr,
      'nameEn': nameEn,
      'requiresSpecification': requiresSpecification,
    };
  }

  factory Allergen.fromMap(Map<String, dynamic> map) {
    return Allergen(
      id: map['id'] as String,
      nameFr: map['nameFr'] as String,
      nameEn: map['nameEn'] as String,
      requiresSpecification: map['requiresSpecification'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Allergen.fromJson(String source) =>
      Allergen.fromMap(json.decode(source) as Map<String, dynamic>);

  Allergen copyWith({
    String? id,
    String? nameFr,
    String? nameEn,
    bool? requiresSpecification,
  }) {
    return Allergen(
      id: id ?? this.id,
      nameFr: nameFr ?? this.nameFr,
      nameEn: nameEn ?? this.nameEn,
      requiresSpecification:
          requiresSpecification ?? this.requiresSpecification,
    );
  }

  @override
  bool operator ==(covariant Allergen other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.nameFr == nameFr &&
        other.nameEn == nameEn &&
        other.requiresSpecification == requiresSpecification;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nameFr.hashCode ^
        nameEn.hashCode ^
        requiresSpecification.hashCode;
  }
}
