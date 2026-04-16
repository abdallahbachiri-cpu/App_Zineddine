import 'dart:developer' as devtools;

import 'package:cuisinous/core/errors/exceptions.dart';
import 'package:cuisinous/data/models/category.dart';
import 'package:cuisinous/data/models/category_type.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:dio/dio.dart';

import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:flutter/material.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

class CategoryProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;

  CategoryProvider({
    required ApiClient apiClient,
    required AuthProvider authProvider,
  }) : _apiClient = apiClient,
       _authProvider = authProvider;

  List<CategoryType> _categoryTypes = [];
  bool _isTypesLoading = false;
  String? _typesError;

  List<Category> _categories = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _isLoading = false;
  String? _categoriesError;

  Category? _selectedCategory;
  bool _isDetailLoading = false;
  String? _detailError;

  List<CategoryType> get categoryTypes => _categoryTypes;
  bool get isTypesLoading => _isTypesLoading;
  String? get typesError => _typesError;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get categoriesError => _categoriesError;
  Category? get selectedCategory => _selectedCategory;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  bool get canLoadMore => _currentPage < _totalPages;

  Future<void> fetchCategoryTypes({String locale = 'en'}) async {
    try {
      _isTypesLoading = true;
      _typesError = null;
      notifyListeners();
      if (!_authProvider.isLoading && _authProvider.type == null) {
        throw const ApiException(400, 'User type not available');
      }
      final response = await _apiClient.get(
        ApiEndpoints.categoryTypes(_authProvider.type!),
        queryParameters: {'locale': locale},
      );

      if (response.statusCode == 200) {
        _categoryTypes =
            (response.data as List)
                .map((type) => CategoryType.fromMap(type))
                .toList();
        devtools.log('[Categories] Fetched ${_categoryTypes.length} types');
      } else {
        throw ApiFailure('Failed to fetch category types', response.statusCode);
      }
    } on DioException catch (e) {
      _typesError = 'Failed to load types: ${e.message}';
      devtools.log('[Categories] API error: ${e.response?.data}', error: e);
    } catch (e, stackTrace) {
      _typesError = 'An unexpected error occurred';
      devtools.log('[Categories] Error: $e', error: e, stackTrace: stackTrace);
    } finally {
      _isTypesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories({
    String? search,
    String? type,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      _categoriesError = null;
      notifyListeners();
      if (!_authProvider.isLoading && _authProvider.type == null) {
        throw const ApiException(400, 'User type not available');
      }
      final queryParams = {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (search != null && search.isNotEmpty) 'search': search,
        if (type != null && type.isNotEmpty) 'type': type,
      };

      final response = await _apiClient.get(
        ApiEndpoints.categories(_authProvider.type!),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _currentPage = data['current_page'];
        _totalPages = data['total_pages'];
        _totalItems = data['total_items'];

        if (page == 1) _categories.clear();
        _categories.addAll(
          (data['data'] as List).map((item) => Category.fromMap(item)),
        );
        devtools.log('[Categories] Fetched page $_currentPage');
      } else {
        throw ApiFailure('Failed to fetch categories', response.statusCode);
      }
    } on DioException catch (e) {
      _categoriesError = 'Failed to load categories: ${e.message}';
      devtools.log('[Categories] API error: ${e.response?.data}', error: e);
    } catch (e, stackTrace) {
      _categoriesError = 'An unexpected error occurred';
      devtools.log('[Categories] Error: $e', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCategoryById(String id) async {
    try {
      _isDetailLoading = true;
      _detailError = null;
      notifyListeners();
      if (!_authProvider.isLoading && _authProvider.type == null) {
        throw const ApiException(400, 'User type not available');
      }
      final response = await _apiClient.get(
        ApiEndpoints.category(_authProvider.type!, id),
      );

      if (response.statusCode == 200) {
        _selectedCategory = Category.fromMap(response.data);
        devtools.log('[Categories] Fetched category $id');
      } else {
        throw ApiFailure('Failed to fetch category', response.statusCode);
      }
    } on DioException catch (e) {
      _detailError = 'Failed to load category: ${e.message}';
      devtools.log('[Categories] API error: ${e.response?.data}', error: e);
    } catch (e, stackTrace) {
      _detailError = 'An unexpected error occurred';
      devtools.log('[Categories] Error: $e', error: e, stackTrace: stackTrace);
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDishCategory(String dishId, String categoryId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sellerDishCategories(dishId),
        body: {'categoryId': categoryId},
      );

      if (response.statusCode == 200) {
        devtools.log('[Categories] Added category $categoryId to dish $dishId');
      } else {
        throw ApiFailure('Failed to add category', response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiFailure(
        e.message ?? 'Failed to add category',
        e.response?.statusCode,
      );
    }
  }

  Future<void> removeDishCategory(String dishId, String categoryId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.sellerDishCategory(dishId, categoryId),
      );

      if (response.statusCode == 200) {
        devtools.log(
          '[Categories] Removed category $categoryId from dish $dishId',
        );
      } else {
        throw ApiFailure('Failed to remove category', response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiFailure(
        e.message ?? 'Failed to remove category',
        e.response?.statusCode,
      );
    }
  }

  Future<void> loadMoreCategories() async {
    if (!canLoadMore || _isLoading) return;
    _currentPage++;
    await fetchCategories(page: _currentPage);
  }

  void clearErrors() {
    _typesError = null;
    _categoriesError = null;
    _detailError = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCategory = null;
    notifyListeners();
  }
}
