import 'dart:developer' as devtools;

import 'package:cuisinous/data/models/dish.dart';
import 'package:cuisinous/data/models/dish_ingredient.dart';
import 'package:cuisinous/data/models/dish_allergen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cuisinous/data/models/category.dart';

import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import '../core/mixins/error_handling_mixin.dart';
import '../core/ui/view_state.dart';

class DishProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;

  DishProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  Dish? _selectedDish;
  ViewState _viewState = ViewState.initial;

  final List<Dish> _dishes = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 50;
  String _search = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'DESC';
  double? _minPrice;
  double? _maxPrice;
  bool _available = true;
  List<String> _ingredients = [];
  int _searchRequestId = 0;

  Dish? get selectedDish => _selectedDish;
  ViewState get viewState => _viewState;
  bool get isLoading => _viewState == ViewState.loading;

  List<Dish> get dishes => _dishes;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get canLoadMore => _currentPage < _totalPages;

  String get search => _search;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  List<String> get categories => List.unmodifiable(_categories);
  List<String> get ingredients => List.unmodifiable(_ingredients);
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  bool get available => _available;

  Future<void> getDishDetails(String id) async {
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.buyerDish(id));
      _selectedDish = Dish.fromMap(response.data);
      _viewState = ViewState.success;
      devtools.log('[BuyerDishes] Fetched dish details for $id');
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to load dish details',
      );
    }
    notifyListeners();
  }

  List<String> _categories = [];

  bool get hasActiveFilters {
    return _search.isNotEmpty ||
        _minPrice != null ||
        _maxPrice != null ||
        !_available ||
        _ingredients.isNotEmpty ||
        _categories.isNotEmpty ||
        _sortBy != 'createdAt' ||
        _sortOrder != 'DESC';
  }

  Future<void> searchDishes({
    String search = '',
    String? sortBy,
    String? sortOrder,
    double? minPrice,
    double? maxPrice,
    bool available = true,
    List<String>? ingredients,
    List<String>? categories,
    int page = 1,
    int limit = 50,
  }) async {
    final int currentRequestId = ++_searchRequestId;

    if (page > 1 && _viewState == ViewState.loading) {
      return;
    }

    if (page == 1) {
      _viewState = ViewState.loading;
      notifyListeners();
    }

    clearError();

    try {
      final queryParameters = {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
        'available': available,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
      };

      if (categories != null && categories.isNotEmpty) {
        queryParameters['categories[]'] = categories;
      }

      if (ingredients != null && ingredients.isNotEmpty) {
        queryParameters['ingredients[]'] = ingredients;
      }

      final response = await _apiClient.get(
        ApiEndpoints.buyerDishes,
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      _currentPage = data['current_page'] as int;
      _totalPages = data['total_pages'] as int;
      _totalItems = data['total_items'] as int;
      _limit = data['limit'] as int;

      final List<dynamic> dishesData = data['data'];

      if (currentRequestId != _searchRequestId) {
        return;
      }

      if (page == 1) _dishes.clear();
      _dishes.addAll(dishesData.map((item) => Dish.fromMap(item)));
      _viewState = ViewState.success;
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to search dishes');
    }
    notifyListeners();
  }

  Future<void> loadMoreDishes() async {
    if (!canLoadMore || _viewState == ViewState.loading) return;
    _currentPage++;
    await searchDishes(
      page: _currentPage,
      limit: _limit,
      search: _search,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      available: _available,
      ingredients: _ingredients,
      categories: _categories,
    );
  }

  void setFilters({
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? available,
    List<String>? ingredients,
    List<String>? categories,
    String? sortBy,
    String? sortOrder,
  }) {
    _search = search ?? _search;
    _minPrice = minPrice ?? _minPrice;
    _maxPrice = maxPrice ?? _maxPrice;
    _available = available ?? _available;
    _ingredients = ingredients ?? _ingredients;
    _categories = categories ?? _categories;
    _sortBy = sortBy ?? _sortBy;
    _sortOrder = sortOrder ?? _sortOrder;
    _currentPage = 1;
    searchDishes(
      page: 1,
      limit: _limit,
      search: _search,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      available: _available,
      ingredients: _ingredients,
      categories: _categories,
    );
  }

  void clearFilters() {
    _search = '';
    _minPrice = null;
    _maxPrice = null;
    _available = true;
    _ingredients = [];
    _categories = [];
    _sortBy = 'createdAt';
    _sortOrder = 'DESC';
    _currentPage = 1;
    searchDishes(
      page: 1,
      limit: _limit,
      search: _search,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      available: _available,
      ingredients: _ingredients,
      categories: _categories,
    );
  }

  void setSorting({String? sortBy, String? sortOrder}) {
    _sortBy = sortBy ?? _sortBy;
    _sortOrder = (sortOrder?.toUpperCase() == 'ASC') ? 'ASC' : 'DESC';
    _currentPage = 1;
    searchDishes(
      page: 1,
      limit: _limit,
      search: _search,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      available: _available,
      ingredients: _ingredients,
      categories: _categories,
    );
  }

  void clearSelection({bool notify = true}) {
    _selectedDish = null;
    if (notify) {
      notifyListeners();
    }
  }

  void clearSearch() {
    _dishes.clear();
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    notifyListeners();
  }
}

class SellerDishProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;

  SellerDishProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  final List<Dish> _dishes = [];
  Dish? _selectedDish;
  ViewState _viewState = ViewState.initial;
  bool _isProcessing = false;

  List<Dish> get dishes => _dishes;
  Dish? get selectedDish => _selectedDish;
  ViewState get viewState => _viewState;
  bool get isLoading => _viewState == ViewState.loading;
  bool get isProcessing => _isProcessing;

  Future<void> fetchDishes() async {
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.sellerDishes);

      _dishes.clear();
      final List<dynamic> data = response.data;
      _dishes.addAll(data.map((item) => Dish.fromMap(item)));
      _viewState = ViewState.success;
      devtools.log('[Dishes] Fetched ${_dishes.length} dishes');
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to load dishes');
    }
    notifyListeners();
  }

  Future<void> createDish({
    required String name,
    required double price,
    String? description,
    required List<XFile> gallery,
  }) async {
    try {
      _isProcessing = true;
      clearError();
      notifyListeners();

      final formData = FormData();

      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('price', price.toString()),
        if (description != null && description.isNotEmpty)
          MapEntry('description', description),
      ]);

      for (final xfile in gallery) {
        final file = await MultipartFile.fromFile(
          xfile.path,
          filename: xfile.name,
        );
        formData.files.add(MapEntry('gallery[]', file));
      }

      await _apiClient.postMultipart(ApiEndpoints.sellerDishes, formData);

      await fetchDishes();
      devtools.log('[Dishes] Created new dish with ${gallery.length} images');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to create dish');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> getDishById(String id) async {
    _viewState = ViewState.loading;
    clearError();
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.sellerDish(id));
      _selectedDish = Dish.fromMap(response.data);
      _viewState = ViewState.success;
      devtools.log('[Dishes] Fetched dish $id');
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to load dish');
    }
    notifyListeners();
  }

  Future<void> updateDish({
    required String id,
    required String name,
    required String description,
    required double price,
    required List<XFile> gallery,
  }) async {
    try {
      _isProcessing = true;
      clearError();
      notifyListeners();

      final data = {'name': name, 'description': description, 'price': price};

      await _apiClient.patch(ApiEndpoints.sellerDish(id), body: data);

      final formData = FormData();
      for (final xfile in gallery) {
        final file = await MultipartFile.fromFile(
          xfile.path,
          filename: xfile.name,
        );
        formData.files.add(MapEntry('gallery[]', file));
      }

      await _apiClient.postMultipart(
        ApiEndpoints.sellerDishAddImages(id),
        formData,
      );

      await fetchDishes();
      devtools.log('[Dishes] Updated dish $id');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to update dish');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> deleteDish(String id) async {
    try {
      _isProcessing = true;
      clearError();
      notifyListeners();

      await _apiClient.delete(ApiEndpoints.sellerDish(id));

      _dishes.removeWhere((dish) => dish.id == id);
      devtools.log('[Dishes] Deleted dish $id');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to delete dish');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void updateSelectedDish(List<Category> categories) {
    if (_selectedDish == null) return;
    _selectedDish = _selectedDish!.copyWith(
      categories: categories as List<Category>?,
    );
    notifyListeners();
  }

  void updateSelectedDishIngredients(DishIngredient ingredient, bool? isAdded) {
    if (_selectedDish == null) return;

    List<DishIngredient> ingredients =
        _selectedDish!.ingredients?.toList() ?? [];

    if (isAdded == null) {
      ingredients.removeWhere((item) => item.id == ingredient.id);
      ingredients.add(ingredient);
    } else {
      isAdded
          ? ingredients.add(ingredient)
          : ingredients.removeWhere((item) => item.id == ingredient.id);
    }
    _selectedDish = _selectedDish!.copyWith(ingredients: ingredients);
    notifyListeners();
  }

  void updateSelectedDishAllergens(DishAllergen allergen) {
    if (_selectedDish == null) return;

    List<DishAllergen> allergens = _selectedDish!.allergens?.toList() ?? [];

    allergens.add(allergen);
    _selectedDish = _selectedDish!.copyWith(allergens: allergens);
    notifyListeners();
  }

  void removeSelectedDishAllergen(String allergenId) {
    if (_selectedDish == null) return;

    List<DishAllergen> allergens = _selectedDish!.allergens?.toList() ?? [];

    allergens.removeWhere((item) => item.allergenId == allergenId);
    _selectedDish = _selectedDish!.copyWith(allergens: allergens);
    notifyListeners();
  }

  Future<void> deleteMedia(String dishId, String mediaId) async {
    try {
      _isProcessing = true;
      clearError();
      notifyListeners();

      await _apiClient.delete(ApiEndpoints.sellerDishMedia(dishId, mediaId));

      final dishIndex = _dishes.indexWhere((d) => d.id == dishId);
      if (dishIndex != -1) {
        _dishes[dishIndex] = _dishes[dishIndex].copyWith(
          gallery:
              _dishes[dishIndex].gallery.where((m) => m.id != mediaId).toList(),
        );
      }

      if (_selectedDish?.id == dishId) {
        _selectedDish = _selectedDish!.copyWith(
          gallery:
              _selectedDish!.gallery.where((m) => m.id != mediaId).toList(),
        );
      }

      devtools.log('[Dishes] Deleted media $mediaId from dish $dishId');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to delete media');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> activateDish(String id) async {
    try {
      _isProcessing = true;
      clearError();
      notifyListeners();

      await _apiClient.post(ApiEndpoints.sellerDishActivate(id));
      await fetchDishes();

      if (_selectedDish?.id == id) {
        await getDishById(id);
      }

      devtools.log('[Dishes] Activated dish $id');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to activate dish');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> deactivateDish(String id) async {
    try {
      _isProcessing = true;
      clearError();
      notifyListeners();

      await _apiClient.post(ApiEndpoints.sellerDishDeactivate(id));
      await fetchDishes();

      if (_selectedDish?.id == id) {
        await getDishById(id);
      }

      devtools.log('[Dishes] Deactivated dish $id');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to deactivate dish');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearSelection({bool notify = true}) {
    _selectedDish = null;
    if (notify) {
      notifyListeners();
    }
  }
}
