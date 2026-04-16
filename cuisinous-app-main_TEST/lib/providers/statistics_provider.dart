import 'dart:developer' as devtools;

import 'package:flutter/foundation.dart';

import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:cuisinous/core/mixins/error_handling_mixin.dart';
import 'package:cuisinous/core/ui/view_state.dart';
import 'package:cuisinous/data/models/seller_stats.dart';
import 'package:cuisinous/services/network/api_client_service.dart';

class StatisticsProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;

  StatisticsProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  SellerStats? _sellerStats;
  DailyRevenueStats? _dailyRevenueStats;
  MonthlyRevenueStats? _monthlyRevenueStats;
  YearlyRevenueStats? _yearlyRevenueStats;

  ViewState _viewState = ViewState.initial;
  ViewState _monthlyViewState = ViewState.initial;
  ViewState _dailyViewState = ViewState.initial;

  SellerStats? get sellerStats => _sellerStats;
  DailyRevenueStats? get dailyRevenueStats => _dailyRevenueStats;
  MonthlyRevenueStats? get monthlyRevenueStats => _monthlyRevenueStats;
  YearlyRevenueStats? get yearlyRevenueStats => _yearlyRevenueStats;

  ViewState get viewState => _viewState;
  ViewState get monthlyViewState => _monthlyViewState;
  ViewState get dailyViewState => _dailyViewState;

  bool get isLoading => _viewState == ViewState.loading;
  bool get isMonthlyLoading => _monthlyViewState == ViewState.loading;
  bool get isDailyLoading => _dailyViewState == ViewState.loading;

  Future<void> fetchSellerStats() async {
    _viewState = ViewState.loading;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.sellerStats);

      if (response.statusCode == 200) {
        _sellerStats = SellerStats.fromMap(response.data);
        _viewState = ViewState.success;
        devtools.log('[StatisticsProvider] Fetched seller stats');
      }
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to fetch seller statistics',
      );
    }
    notifyListeners();
  }

  Future<void> fetchRevenueByDay(int year, int month) async {
    _dailyViewState = ViewState.loading;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        ApiEndpoints.sellerStatsRevenueByMonth(year, month),
      );

      if (response.statusCode == 200) {
        _dailyRevenueStats = DailyRevenueStats.fromMap(response.data);
        _dailyViewState = ViewState.success;
        devtools.log(
          '[StatisticsProvider] Fetched revenue by day for $month/$year',
        );
      }
    } catch (e, stackTrace) {
      _dailyViewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to fetch daily revenue',
      );
    }
    notifyListeners();
  }

  Future<void> fetchRevenueByMonth(int year) async {
    _monthlyViewState = ViewState.loading;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        ApiEndpoints.sellerStatsRevenueByYear(year),
      );

      if (response.statusCode == 200) {
        _monthlyRevenueStats = MonthlyRevenueStats.fromMap(response.data);
        _monthlyViewState = ViewState.success;
        devtools.log('[StatisticsProvider] Fetched revenue by month for $year');
      }
    } catch (e, stackTrace) {
      _monthlyViewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to fetch monthly revenue',
      );
    }
    notifyListeners();
  }

  Future<void> fetchRevenueAllYears() async {
    if (_viewState != ViewState.loading) {
      _viewState = ViewState.loading;
      notifyListeners();
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.sellerStatsRevenue);

      if (response.statusCode == 200) {
        _yearlyRevenueStats = YearlyRevenueStats.fromMap(response.data);

        _viewState = ViewState.success;
        devtools.log('[StatisticsProvider] Fetched revenue for all years');
      }
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to fetch yearly revenue',
      );
    }
    notifyListeners();
  }

  void clearStats() {
    _sellerStats = null;
    _dailyRevenueStats = null;
    _monthlyRevenueStats = null;
    _yearlyRevenueStats = null;
    _viewState = ViewState.initial;
    _monthlyViewState = ViewState.initial;
    _dailyViewState = ViewState.initial;
    notifyListeners();
  }
}
