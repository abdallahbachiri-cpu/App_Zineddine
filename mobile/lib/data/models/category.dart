import 'dart:convert';

class Category {
  final String id;
  final String type;
  final String nameFr;
  final String nameEn;

  Category({
    required this.id,
    required this.type,
    required this.nameFr,
    required this.nameEn,
  });

  Category copyWith({
    String? id,
    String? type,
    String? nameFr,
    String? nameEn,
  }) {
    return Category(
      id: id ?? this.id,
      type: type ?? this.type,
      nameFr: nameFr ?? this.nameFr,
      nameEn: nameEn ?? this.nameEn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'nameFr': nameFr,
      'nameEn': nameEn,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      type: map['type'] as String,
      nameFr: map['nameFr'] as String,
      nameEn: map['nameEn'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source) as Map<String, dynamic>);
}
