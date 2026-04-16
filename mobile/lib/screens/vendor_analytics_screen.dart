import 'package:cuisinous/core/ui/view_state.dart';
import 'package:cuisinous/providers/statistics_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cuisinous/core/utils/currency_formatter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cuisinous/generated/l10n.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StatisticsProvider>();
      provider.fetchSellerStats();
      provider.fetchRevenueAllYears();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          S.of(context).sellerStats_title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, child) {
          if (provider.viewState == ViewState.loading &&
              provider.sellerStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.viewState == ViewState.error &&
              provider.sellerStats == null) {
            return Center(
              child: Text(
                'Error: ${provider.error ?? "Unknown error"}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchSellerStats();
              await provider.fetchRevenueAllYears();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummarySection(context, provider),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    context,
                    S.of(context).sellerStats_yearlyRevenue,
                  ),
                  const SizedBox(height: 16),
                  _buildYearlySection(context, provider),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    context,
                    S.of(context).sellerStats_monthlyRevenue,
                  ),
                  const SizedBox(height: 16),
                  _MonthlyRevenueView(
                    provider: provider,
                    initialYear: DateTime.now().year,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    context,
                    S.of(context).sellerStats_dailyRevenue,
                  ),
                  const SizedBox(height: 16),
                  _DailyRevenueView(
                    provider: provider,
                    initialYear: DateTime.now().year,
                    initialMonth: DateTime.now().month,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    final stats = provider.sellerStats;
    if (stats == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildSummaryCard(
          context,
          S.of(context).sellerStats_totalOrders,
          stats.totalOrders.toString(),
          Icons.shopping_bag_outlined,
          const Color(0xFF6C63FF),
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          context,
          S.of(context).sellerHome_pendingOrders,
          stats.totalPendingOrders.toString(),
          Icons.pending_actions_outlined,
          const Color(0xFFFFB74D),
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          context,
          S.of(context).sellerHome_totalRevenue,
          CurrencyFormatter.format(stats.totalRevenue),
          Icons.attach_money,
          const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildYearlySection(
    BuildContext context,
    StatisticsProvider provider,
  ) {
    final yearlyStats = provider.yearlyRevenueStats;
    final currentYear = DateTime.now().year;

    final data =
        (yearlyStats != null && yearlyStats.revenueByYear.isNotEmpty)
            ? yearlyStats.revenueByYear
            : {currentYear: 0.0};

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _RevenueBarChart(
        data: data,
        xLabelBuilder: (value) => value.toInt().toString(),
        barColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyRevenueView extends StatefulWidget {
  final StatisticsProvider provider;
  final int initialYear;

  const _MonthlyRevenueView({
    required this.provider,
    required this.initialYear,
  });

  @override
  State<_MonthlyRevenueView> createState() => _MonthlyRevenueViewState();
}

class _MonthlyRevenueViewState extends State<_MonthlyRevenueView> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.fetchRevenueByMonth(_selectedYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.provider.monthlyRevenueStats;
    final isLoading = widget.provider.isMonthlyLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_selectedYear',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  borderRadius: BorderRadius.circular(16),
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem(value: year, child: Text('$year'));
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedYear = val);
                      widget.provider.fetchRevenueByMonth(val);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 200,
              child: _RevenueBarChart(
                data:
                    (stats != null && stats.revenueByMonth.isNotEmpty)
                        ? stats.revenueByMonth
                        : {1: 0.0},
                xLabelBuilder: (value) {
                  final month = value.toInt();
                  if (month >= 1 && month <= 12) {
                    return DateFormat('MMM').format(DateTime(0, month));
                  }
                  return '';
                },
                barColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyRevenueView extends StatefulWidget {
  final StatisticsProvider provider;
  final int initialYear;
  final int initialMonth;

  const _DailyRevenueView({
    required this.provider,
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<_DailyRevenueView> createState() => _DailyRevenueViewState();
}

class _DailyRevenueViewState extends State<_DailyRevenueView> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    widget.provider.fetchRevenueByDay(_selectedYear, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.provider.dailyRevenueStats;
    final isLoading = widget.provider.isDailyLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  borderRadius: BorderRadius.circular(16),
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem(value: year, child: Text('$year'));
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedYear = val);
                      _fetchData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  borderRadius: BorderRadius.circular(16),
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(DateFormat('MMM').format(DateTime(0, month))),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMonth = val);
                      _fetchData();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 200,
              child: _RevenueBarChart(
                data:
                    (stats != null && stats.revenueByDay.isNotEmpty)
                        ? stats.revenueByDay
                        : {1: 0.0},
                xLabelBuilder: (value) => value.toInt().toString(),
                barColor: const Color(0xFFFFB74D),
                bottomTitleInterval: 5,
              ),
            ),
        ],
      ),
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  final Map<int, double> data;
  final String Function(double) xLabelBuilder;
  final Color barColor;
  final double? bottomTitleInterval;

  const _RevenueBarChart({
    required this.data,
    required this.xLabelBuilder,
    required this.barColor,
    this.bottomTitleInterval,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data.values.fold<double>(0, (p, c) => c > p ? c : p);
    final maxY = maxValue * 1.2;
    final effectiveMaxY = maxY == 0 ? 100.0 : maxY;
    final sortedKeys = data.keys.toList()..sort();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: effectiveMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                CurrencyFormatter.formatCompact(rod.toY),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomTitleInterval,
              getTitlesWidget: (value, meta) {
                if (bottomTitleInterval != null &&
                    value % bottomTitleInterval! != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    xLabelBuilder(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    CurrencyFormatter.formatCompact(value),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: effectiveMaxY / 5,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            sortedKeys.map((key) {
              return BarChartGroupData(
                x: key,
                barRods: [
                  BarChartRodData(
                    toY: data[key]!,
                    color: barColor,
                    width: 8,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: effectiveMaxY,
                      color: Colors.grey[50]!,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
