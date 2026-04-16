class Ingredient {
  final String id;
  final String nameFr;
  final String nameEn;

  Ingredient({required this.id, required this.nameFr, required this.nameEn});

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as String,
      nameFr: map['nameFr'] as String,
      nameEn: map['nameEn'] as String,
    );
  }
}
