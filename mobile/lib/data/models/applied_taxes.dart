class AppliedTaxes {
  final Map<String, double> rates;

  AppliedTaxes({required this.rates});

  factory AppliedTaxes.fromJson(Map<String, dynamic> json) => AppliedTaxes(
    rates: Map<String, double>.from(
      (json['rates'] as Map<String, dynamic>).map((key, value) {
        if (value is num) {
          return MapEntry(key, value.toDouble());
        } else if (value is String) {
          return MapEntry(key, double.tryParse(value) ?? 0.0);
        }
        return MapEntry(key, 0.0);
      }),
    ),
  );

  Map<String, dynamic> toJson() => {'rates': rates, 'amounts': []};
}
