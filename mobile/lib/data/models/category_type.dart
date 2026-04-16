class CategoryType {
  final String value;
  final String labelEn;
  final String labelFr;
  final String label;

  CategoryType({
    required this.value,
    required this.labelEn,
    required this.labelFr,
    required this.label,
  });

  factory CategoryType.fromMap(Map<String, dynamic> map) => CategoryType(
    value: map['value'],
    labelEn: map['labelEn'],
    labelFr: map['labelFr'],
    label: map['label'],
  );
}
