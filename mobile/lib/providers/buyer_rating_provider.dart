import 'dart:developer' as devtools;

import 'package:cuisinous/data/models/rating.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/services/network/api_client_service.dart';

class BuyerRatingProvider with ChangeNotifier {
  final ApiClient _apiClient;

  BuyerRatingProvider({required ApiClient apiClient}) : _apiClient = apiClient;

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

  final List<Rating> _userRatings = [];
  int _userCurrentPage = 1;
  int _userTotalPages = 1;
  int _userTotalItems = 0;
  int _userLimit = 10;
  String _userSortBy = 'createdAt';
  String _userSortOrder = 'DESC';
  int? _userMinRating;
  int? _userMaxRating;
  bool _isUserLoading = false;
  String? _userError;

  Rating? _selectedRating;
  bool _isDetailLoading = false;
  String? _detailError;

  bool _isCreating = false;
  String? _createError;
  bool _isUpdating = false;
  String? _updateError;

  List<Rating> get dishRatings => _dishRatings;
  bool get isDishLoading => _isDishLoading;
  String? get dishError => _dishError;
  int get dishCurrentPage => _dishCurrentPage;
  int get dishTotalPages => _dishTotalPages;
  bool get canLoadMoreDish => _dishCurrentPage < _dishTotalPages;

  List<Rating> get userRatings => _userRatings;
  bool get isUserLoading => _isUserLoading;
  String? get userError => _userError;
  int get userCurrentPage => _userCurrentPage;
  int get userTotalPages => _userTotalPages;
  bool get canLoadMoreUser => _userCurrentPage < _userTotalPages;

  Rating? get selectedRating => _selectedRating;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  bool get isCreating => _isCreating;
  String? get createError => _createError;
  bool get isUpdating => _isUpdating;
  String? get updateError => _updateError;

  Future<void> fetchDishRatings(String dishId, {bool refresh = false}) async {
    if (_isDishLoading) return;
    _currentDishId = dishId;

    try {
      _isDishLoading = true;
      _dishError = null;
      notifyListeners();

      if (refresh) {
        _dishCurrentPage = 1;
      }
      _dishRatings.clear();
      devtools.log(
        '[Ratings] Fetching dish $dishId ratings page ${_buildDishQueryParams()}',
      );
      final response = await _apiClient.get(
        ApiEndpoints.buyerDishRatings(dishId),
      );

      _handleDishResponse(response);
      devtools.log(
        '[Ratings] Fetched dish $dishId ratings page $_dishCurrentPage',
      );
    } on DioException catch (e) {
      _dishError = _parseDioError(e, 'Failed to load dish ratings');
      devtools.log(
        '[Ratings] Dish ratings error: ${e.response?.data}',
        error: e,
      );
    } catch (e, stackTrace) {
      _dishError = 'An unexpected error occurred';
      devtools.log('[Ratings] Error: $e', error: e, stackTrace: stackTrace);
    } finally {
      _isDishLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildDishQueryParams() => {
    'page': _dishCurrentPage,
    'limit': _dishLimit,
    'sortBy': _dishSortBy,
    'sortOrder': _dishSortOrder,
    'minRating': _dishMinRating,
    'maxRating': _dishMaxRating,
  };

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

  Future<void> fetchUserRatings({bool refresh = false}) async {
    if (_isUserLoading) return;

    try {
      _isUserLoading = true;
      _userError = null;
      notifyListeners();

      if (refresh) {
        _userCurrentPage = 1;
        _userRatings.clear();
      }

      final response = await _apiClient.get(ApiEndpoints.buyerRatings);

      _handleUserResponse(response);
      devtools.log('[Ratings] Fetched user ratings page $_userCurrentPage');
    } on DioException catch (e) {
      _userError = _parseDioError(e, 'Failed to load user ratings');
      devtools.log(
        '[Ratings] User ratings error: ${e.response?.data}',
        error: e,
      );
    } catch (e, stackTrace) {
      _userError = 'An unexpected error occurred';
      devtools.log('[Ratings] Error: $e', error: e, stackTrace: stackTrace);
    } finally {
      _isUserLoading = false;
      notifyListeners();
    }
  }

  void _handleUserResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      _validateResponseStructure(data);

      _userRatings.addAll(
        (data['data'] as List).map((item) => Rating.fromMap(item)).toList(),
      );

      _userCurrentPage = data['current_page'] as int;
      _userTotalPages = data['total_pages'] as int;
      _userTotalItems = data['total_items'] as int;
      _userLimit = data['limit'] as int;
    } else {
      throw ApiFailure('Unexpected status code', response.statusCode);
    }
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

  Future<void> createRating({
    required String dishId,
    required int rating,
    required String orderId,
    String? comment,
  }) async {
    if (_isCreating) return;

    try {
      _isCreating = true;
      _createError = null;
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.buyerDishRatings(dishId),
        body: {
          'orderId': orderId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      if (response.statusCode == 201) {
        await Future.wait([
          if (_currentDishId == dishId) fetchDishRatings(dishId, refresh: true),
          fetchUserRatings(refresh: true),
        ]);
      }
    } on DioException catch (e) {
      _createError = _parseDioError(e, 'Failed to create rating');
    } catch (e, stackTrace) {
      _createError = 'An unexpected error occurred';
      devtools.log(
        '[Ratings] Create error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> updateRating({
    required String ratingId,
    int? rating,
    String? comment,
  }) async {
    if (_isUpdating) return;

    try {
      _isUpdating = true;
      _updateError = null;
      notifyListeners();

      final Map<String, dynamic> data = {};
      if (rating != null) data['rating'] = rating;
      if (comment != null) data['comment'] = comment;

      final response = await _apiClient.patch(
        ApiEndpoints.buyerRating(ratingId),
        body: data,
      );

      if (response.statusCode == 200) {
        final updatedRating = Rating.fromMap(response.data);
        _updateRatingInLists(updatedRating);
        if (_selectedRating?.id == ratingId) {
          _selectedRating = updatedRating;
        }
      }
    } on DioException catch (e) {
      _updateError = _parseDioError(e, 'Failed to update rating');
    } catch (e, stackTrace) {
      _updateError = 'An unexpected error occurred';
      devtools.log(
        '[Ratings] Update error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void _updateRatingInLists(Rating updatedRating) {
    void updateList(List<Rating> list) {
      final index = list.indexWhere((r) => r.id == updatedRating.id);
      if (index != -1) list[index] = updatedRating;
    }

    updateList(_dishRatings);
    updateList(_userRatings);
  }

  Future<void> getRatingById(String ratingId) async {
    try {
      _isDetailLoading = true;
      _detailError = null;
      notifyListeners();

      final response = await _apiClient.get(ApiEndpoints.buyerRating(ratingId));

      if (response.statusCode == 200) {
        _selectedRating = Rating.fromMap(response.data);
      } else {
        throw ApiFailure('Failed to fetch rating', response.statusCode);
      }
    } on DioException catch (e) {
      _detailError = _parseDioError(e, 'Failed to fetch rating');
    } catch (e, stackTrace) {
      _detailError = 'An unexpected error occurred';
      devtools.log(
        '[Ratings] Detail error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
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

  void setUserFilters({
    int? minRating,
    int? maxRating,
    String? sortBy,
    String? sortOrder,
  }) {
    _userMinRating = minRating?.clamp(1, 5);
    _userMaxRating = maxRating?.clamp(1, 5);
    _userSortBy = sortBy ?? _userSortBy;
    _userSortOrder = (sortOrder?.toUpperCase() == 'ASC') ? 'ASC' : 'DESC';
    _resetUserPagination();
  }

  void _resetDishPagination() {
    _dishCurrentPage = 1;
    _dishRatings.clear();
    if (_currentDishId != null) {
      fetchDishRatings(_currentDishId!);
    }
  }

  void _resetUserPagination() {
    _userCurrentPage = 1;
    _userRatings.clear();
    fetchUserRatings();
  }

  Future<void> loadMoreDishRatings() async {
    if (!canLoadMoreDish || _isDishLoading) return;
    _dishCurrentPage++;
    await fetchDishRatings(_currentDishId!);
  }

  Future<void> loadMoreUserRatings() async {
    if (!canLoadMoreUser || _isUserLoading) return;
    _userCurrentPage++;
    await fetchUserRatings();
  }

  void clearSelectedRating() {
    _selectedRating = null;
    _detailError = null;
    notifyListeners();
  }

  void clearSelectedRatings() {
    _dishRatings.clear();
    _userRatings.clear();
    _selectedRating = null;
    _detailError = null;
    notifyListeners();
  }

  void clearErrors() {
    _dishError = null;
    _userError = null;
    _createError = null;
    _updateError = null;
    notifyListeners();
  }
}
