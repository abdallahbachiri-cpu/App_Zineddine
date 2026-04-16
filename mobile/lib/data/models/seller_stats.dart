class SellerStats {
  final int totalOrders;
  final int totalPendingOrders;
  final double totalRevenue;

  const SellerStats({
    required this.totalOrders,
    required this.totalPendingOrders,
    required this.totalRevenue,
  });

  factory SellerStats.fromMap(Map<String, dynamic> map) {
    return SellerStats(
      totalOrders: map['totalOrders'] as int? ?? 0,
      totalPendingOrders: map['totalPendingOrders'] as int? ?? 0,
      totalRevenue:
          double.tryParse(map['totalRevenue']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DailyRevenueStats {
  final int year;
  final int month;
  final Map<int, double> revenueByDay;

  const DailyRevenueStats({
    required this.year,
    required this.month,
    required this.revenueByDay,
  });

  factory DailyRevenueStats.fromMap(Map<String, dynamic> map) {
    final revenueMap = map['revenueByDay'] as Map<String, dynamic>? ?? {};
    return DailyRevenueStats(
      year: map['year'] as int? ?? 0,
      month: map['month'] as int? ?? 0,
      revenueByDay: revenueMap.map(
        (key, value) => MapEntry(
          int.tryParse(key) ?? 0,
          double.tryParse(value?.toString() ?? '0') ?? 0.0,
        ),
      ),
    );
  }
}

class MonthlyRevenueStats {
  final int year;
  final Map<int, double> revenueByMonth;

  const MonthlyRevenueStats({required this.year, required this.revenueByMonth});

  factory MonthlyRevenueStats.fromMap(Map<String, dynamic> map) {
    final revenueMap = map['revenueByMonth'] as Map<String, dynamic>? ?? {};
    return MonthlyRevenueStats(
      year: map['year'] as int? ?? 0,
      revenueByMonth: revenueMap.map(
        (key, value) => MapEntry(
          int.tryParse(key) ?? 0,
          double.tryParse(value?.toString() ?? '0') ?? 0.0,
        ),
      ),
    );
  }
}

class YearlyRevenueStats {
  final Map<int, double> revenueByYear;

  const YearlyRevenueStats({required this.revenueByYear});

  factory YearlyRevenueStats.fromMap(Map<String, dynamic> map) {
    final revenueMap = map['revenueByYear'] as Map<String, dynamic>? ?? {};
    return YearlyRevenueStats(
      revenueByYear: revenueMap.map(
        (key, value) => MapEntry(
          int.tryParse(key) ?? 0,
          double.tryParse(value?.toString() ?? '0') ?? 0.0,
        ),
      ),
    );
  }
}
