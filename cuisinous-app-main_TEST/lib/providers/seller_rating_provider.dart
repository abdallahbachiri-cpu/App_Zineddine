import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/data/models/rating.dart';
import 'package:flutter/foundation.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as devtools;

class SellerRatingProvider with ChangeNotifier {
  final ApiClient _apiClient;

  SellerRatingProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  final List<Rating> _allRatings = [];
  int _allCurrentPage = 1;
  int _allTotalPages = 1;
  int _allTotalItems = 0;
  int _allLimit = 10;
  String _allSortBy = 'createdAt';
  String _allSortOrder = 'DESC';
  String _search = '';
  String? _buyerId;
  String? _orderId;
  int? _allMinRating;
  int? _allMaxRating;
  bool _isAllLoading = false;
  String? _allError;

  final List<Rating> _dishRatings = [];
  int _dishCurrentPage = 1;
  int _dishTotalPages = 1;
  int _dishTotalItems = 0;
  int _dishLimit = 10;
  String _dishSortBy = 'createdAt';
  String _dishSortOrder = 'DESC';
  int? _dishMinRating;
  int? _dishMaxRating;
  bool _isDishLoading = false;
  String? _dishError;
  String? _currentDishId;

  Rating? _selectedRating;
  bool _isDetailLoading = false;
  String? _detailError;

  List<Rating> get allRatings => _allRatings;
  bool get isAllLoading => _isAllLoading;
  String? get allError => _allError;
  int get allCurrentPage => _allCurrentPage;
  int get allTotalPages => _allTotalPages;
  bool get canLoadMoreAll => _allCurrentPage < _allTotalPages;

  List<Rating> get dishRatings => _dishRatings;
  bool get isDishLoading => _isDishLoading;
  String? get dishError => _dishError;
  int get dishCurrentPage => _dishCurrentPage;
  int get dishTotalPages => _dishTotalPages;
  bool get canLoadMoreDish => _dishCurrentPage < _dishTotalPages;

  Rating? get selectedRating => _selectedRating;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  Future<void> fetchAllRatings({bool refresh = false}) async {
    if (_isAllLoading) return;

    try {
      _isAllLoading = true;
      _allError = null;
      notifyListeners();

      if (refresh) {
        _allCurrentPage = 1;
        _allRatings.clear();
      }

      final response = await _apiClient.get(
        ApiEndpoints.sellerRatings,
        queryParameters: _buildAllQueryParams(),
      );

      _handleAllResponse(response);
      devtools.log('[SellerRatings] Fetched all ratings page $_allCurrentPage');
    } on DioException catch (e) {
      _allError = _parseDioError(e, 'Failed to load ratings');
      devtools.log(
        '[SellerRatings] All ratings error: ${e.response?.data}',
        error: e,
      );
    } catch (e, stackTrace) {
      _allError = 'An unexpected error occurred';
      devtools.log(
        '[SellerRatings] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isAllLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildAllQueryParams() => {
    'page': _allCurrentPage,
    'limit': _allLimit,
    'sortBy': _allSortBy,
    'sortOrder': _allSortOrder,
    'search': _search.isNotEmpty ? _search : null,
    'buyerId': _buyerId,
    'orderId': _orderId,
    'minRating': _allMinRating,
    'maxRating': _allMaxRating,
  };

  void _handleAllResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      _validateResponseStructure(data);

      _allRatings.addAll(
        (data['data'] as List).map((item) => Rating.fromMap(item)).toList(),
      );

      _allCurrentPage = data['current_page'] as int;
      _allTotalPages = data['total_pages'] as int;
      _allTotalItems = data['total_items'] as int;
      _allLimit = data['limit'] as int;
    } else {
      throw ApiFailure('Unexpected status code', response.statusCode);
    }
  }

  Future<void> fetchDishRatings(String dishId, {bool refresh = false}) async {
    if (_isDishLoading) return;
    _currentDishId = dishId;

    try {
      _isDishLoading = true;
      _dishError = null;
      notifyListeners();

      if (refresh) {
        _dishCurrentPage = 1;
        _dishRatings.clear();
      }

      _dishRatings.clear();
      final response = await _apiClient.get(
        ApiEndpoints.sellerDishRatings(dishId),
      );

      _handleDishResponse(response);
      devtools.log(
        '[SellerRatings] Fetched dish $dishId ratings page $_dishCurrentPage',
      );
    } on DioException catch (e) {
      _dishError = _parseDioError(e, 'Failed to load dish ratings');
      devtools.log(
        '[SellerRatings] Dish ratings error: ${e.response?.data}',
        error: e,
      );
    } catch (e, stackTrace) {
      _dishError = 'An unexpected error occurred';
      devtools.log(
        '[SellerRatings] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isDishLoading = false;
      notifyListeners();
    }
  }

  void _handleDishResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      _validateResponseStructure(data);

      _dishRatings.addAll(
        (data['data'] as List).map((item) => Rating.fromMap(item)).toList(),
      );

      _dishCurrentPage = data['current_page'] as int;
      _dishTotalPages = data['total_pages'] as int;
      _dishTotalItems = data['total_items'] as int;
      _dishLimit = data['limit'] as int;
    } else {
      throw ApiFailure('Unexpected status code', response.statusCode);
    }
  }

  Future<void> getRatingDetail(String dishId, String ratingId) async {
    try {
      _isDetailLoading = true;
      _detailError = null;
      notifyListeners();

      final response = await _apiClient.get(
        ApiEndpoints.sellerDishRating(dishId, ratingId),
      );

      if (response.statusCode == 200) {
        _selectedRating = Rating.fromMap(response.data);
      } else {
        throw ApiFailure('Failed to fetch rating', response.statusCode);
      }
    } on DioException catch (e) {
      _detailError = _parseDioError(e, 'Failed to load rating detail');
    } catch (e, stackTrace) {
      _detailError = 'An unexpected error occurred';
      devtools.log(
        '[SellerRatings] Detail error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void setAllFilters({
    String? search,
    String? buyerId,
    String? orderId,
    int? minRating,
    int? maxRating,
    String? sortBy,
    String? sortOrder,
  }) {
    _search = search?.trim() ?? _search;
    _buyerId = buyerId?.trim();
    _orderId = orderId?.trim();
    _allMinRating = minRating?.clamp(1, 5);
    _allMaxRating = maxRating?.clamp(1, 5);
    _allSortBy = sortBy ?? _allSortBy;
    _allSortOrder = (sortOrder?.toUpperCase() == 'ASC') ? 'ASC' : 'DESC';
    _resetAllPagination();
  }

  void setDishFilters({
    int? minRating,
    int? maxRating,
    String? sortBy,
    String? sortOrder,
  }) {
    _dishMinRating = minRating?.clamp(1, 5);
    _dishMaxRating = maxRating?.clamp(1, 5);
    _dishSortBy = sortBy ?? _dishSortBy;
    _dishSortOrder = (sortOrder?.toUpperCase() == 'ASC') ? 'ASC' : 'DESC';
    _resetDishPagination();
  }

  void _resetAllPagination() {
    _allCurrentPage = 1;
    _allRatings.clear();
    fetchAllRatings();
  }

  void _resetDishPagination() {
    _dishCurrentPage = 1;
    _dishRatings.clear();
    if (_currentDishId != null) {
      fetchDishRatings(_currentDishId!);
    }
  }

  Future<void> loadMoreAllRatings() async {
    if (!canLoadMoreAll || _isAllLoading) return;
    _allCurrentPage++;
    await fetchAllRatings();
  }

  Future<void> loadMoreDishRatings() async {
    if (!canLoadMoreDish || _isDishLoading) return;
    _dishCurrentPage++;
    await fetchDishRatings(_currentDishId!);
  }

  void _validateResponseStructure(Map<String, dynamic> data) {
    final requiredKeys = {
      'current_page',
      'limit',
      'total_items',
      'total_pages',
      'data',
    };
    if (!requiredKeys.every(data.containsKey)) {
      throw const FormatException('Invalid ratings response structure');
    }
  }

  String _parseDioError(DioException e, String defaultMessage) {
    if (e.response?.data is Map && e.response?.data['error'] != null) {
      return e.response!.data['error'].toString();
    }
    return '$defaultMessage: ${e.message}';
  }

  void clearSelectedRating({bool notify = true}) {
    _selectedRating = null;
    _detailError = null;
    if (notify) {
      notifyListeners();
    }
  }

  void clearErrors() {
    _allError = null;
    _dishError = null;
    _detailError = null;
    notifyListeners();
  }

  void resetAllFilters() {
    _search = '';
    _buyerId = null;
    _orderId = null;
    _allMinRating = null;
    _allMaxRating = null;
    _allSortBy = 'createdAt';
    _allSortOrder = 'DESC';
    _resetAllPagination();
  }
}
