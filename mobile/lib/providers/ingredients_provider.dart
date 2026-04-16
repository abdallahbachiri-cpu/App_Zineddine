import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/core/mixins/error_handling_mixin.dart';
import 'package:cuisinous/data/models/ingredient.dart';
import 'package:flutter/foundation.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as devtools;

class IngredientsProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;

  IngredientsProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  final List<Ingredient> _ingredients = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 50;
  String _sortBy = 'createdAt';
  String _sortOrder = 'DESC';
  String _search = '';
  bool _isLoading = false;

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get canLoadMore => _currentPage < _totalPages;
  String get currentSort => '$_sortBy:$_sortOrder';

  Future<void> fetchIngredients({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      if (refresh) {
        _currentPage = 1;
        _ingredients.clear();
      }

      final response = await _apiClient.get(
        ApiEndpoints.sellerIngredients,
        queryParameters: {
          'page': _currentPage,
          'limit': _limit,
          'sortBy': _sortBy,
          'sortOrder': _sortOrder,
          'search': _search.isNotEmpty ? _search : null,
        },
      );

      _handleResponse(response);
      devtools.log('[Ingredients] Fetched page $_currentPage');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to load ingredients');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Ingredient? _selectedIngredient;
  bool _isDetailLoading = false;

  Ingredient? get selectedIngredient => _selectedIngredient;
  bool get isDetailLoading => _isDetailLoading;

  Future<void> getIngredientById(String id) async {
    try {
      _isDetailLoading = true;
      clearError();
      _selectedIngredient = null;
      notifyListeners();

      final response = await _apiClient.get(ApiEndpoints.sellerIngredient(id));

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _selectedIngredient = Ingredient.fromMap(data);
        devtools.log('[Ingredients] Fetched ingredient $id');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to load ingredient');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> createIngredient({
    required String nameFr,
    required String nameEn,
  }) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      if (nameFr.isEmpty || nameEn.isEmpty) {
        handleError(
          Exception('Both nameFr and nameEn are required'),
          StackTrace.current,
          fallbackMessage: 'Both nameFr and nameEn are required',
        );
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiClient.post(
        ApiEndpoints.sellerIngredients,
        body: {'nameFr': nameFr, 'nameEn': nameEn},
      );

      if (response.statusCode == 201) {
        final newIngredient = Ingredient.fromMap(response.data);
        _ingredients.insert(0, newIngredient);
        _totalItems++;
        devtools.log('[Ingredients] Created new ingredient');
      }
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to create ingredient',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateIngredient({
    required String id,
    required String nameFr,
    required String nameEn,
  }) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      if (nameFr.isEmpty || nameEn.isEmpty) {
        handleError(
          Exception('Both nameFr and nameEn are required'),
          StackTrace.current,
          fallbackMessage: 'Both nameFr and nameEn are required',
        );
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiClient.patch(
        ApiEndpoints.sellerIngredient(id),
        body: {'nameFr': nameFr, 'nameEn': nameEn},
      );

      if (response.statusCode == 200) {
        final updatedIngredient = Ingredient.fromMap(response.data);

        final index = _ingredients.indexWhere((i) => i.id == id);
        if (index != -1) {
          _ingredients[index] = updatedIngredient;
        }

        if (_selectedIngredient?.id == id) {
          _selectedIngredient = updatedIngredient;
        }

        devtools.log('[Ingredients] Updated ingredient $id');
      }
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to update ingredient',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteIngredient(String id) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.delete(
        ApiEndpoints.sellerIngredient(id),
      );

      if (response.statusCode == 204) {
        _ingredients.removeWhere((i) => i.id == id);
        _totalItems--;

        if (_selectedIngredient?.id == id) {
          _selectedIngredient = null;
        }

        devtools.log('[Ingredients] Deleted ingredient $id');
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to delete ingredient',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void clearSelectedIngredient() {
    _selectedIngredient = null;
    clearError();
    notifyListeners();
  }

  void setSorting({String? sortBy, String? sortOrder}) {
    _sortBy = sortBy?.trim() ?? 'createdAt';
    _sortOrder = (sortOrder?.toUpperCase() == 'ASC') ? 'ASC' : 'DESC';
    _resetPaginationAndFetch();
  }

  void setSearchTerm(String term) {
    _search = term.trim();
    _resetPaginationAndFetch();
  }

  void setLimit(int newLimit) {
    _limit = newLimit > 0 ? newLimit : 50;
    _resetPaginationAndFetch();
  }

  Future<void> loadMoreIngredients() async {
    if (!canLoadMore || _isLoading) return;
    _currentPage++;
    await fetchIngredients();
  }

  void _resetPaginationAndFetch() {
    _currentPage = 1;
    _ingredients.clear();
    fetchIngredients();
  }

  void _handleResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      _validateResponseStructure(data);

      final newIngredients =
          (data['data'] as List)
              .map((item) => Ingredient.fromMap(item))
              .toList();

      _ingredients.addAll(newIngredients);
      _updatePagination(data);
    } else {
      throw ApiFailure(
        'Unexpected status code: ${response.statusCode}',
        response.statusCode,
      );
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
      throw const FormatException('Invalid ingredients response structure');
    }
  }

  void _updatePagination(Map<String, dynamic> data) {
    _currentPage = data['current_page'] as int;
    _totalPages = data['total_pages'] as int;
    _totalItems = data['total_items'] as int;
    _limit = data['limit'] as int;
  }
}
