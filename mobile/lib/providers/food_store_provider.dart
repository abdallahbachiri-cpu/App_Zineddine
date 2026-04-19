import 'dart:developer' as devtools;
import 'dart:io';

import 'package:cuisinous/data/models/dish.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/data/models/verification_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

import '../core/errors/exceptions.dart';
import '../core/mixins/error_handling_mixin.dart';

class FoodStoreProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;

  FoodStore? _currentStore;
  VerificationRequest? _storeRequest;
  bool _isLoading = false;

  FoodStore? get currentStore => _currentStore;
  VerificationRequest? get storeRequest => _storeRequest;
  bool get isLoading => _isLoading;

  FoodStoreProvider({
    required ApiClient apiClient,
    required AuthProvider authProvider,
  }) : _apiClient = apiClient,
       _authProvider = authProvider;

  void _verifySeller() {
    devtools.log('[FoodStore] Verifying seller status');
    if (_authProvider.user?.type != 'seller') {
      devtools.log(
        '[FoodStore] Seller verification failed',
        error: 'User type: ${_authProvider.user?.type}',
      );
      throw ApiException(403, 'Only seller accounts can manage food stores');
    }
    devtools.log('[FoodStore] Seller verification successful');
  }

  Future<void> getMyStore() async {
    devtools.log('[FoodStore] Starting getMyStore');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();
      devtools.log('[FoodStore] Fetching store data');

      final response = await _apiClient.get(ApiEndpoints.sellerFoodStore);
      _currentStore = FoodStore.fromJson(response.data);
      devtools.log('[FoodStore] Store data parsed successfully');
    } on ApiException catch (e, s) {
      if (e.statusCode == 404) {
        _currentStore = null;
        clearError();
      } else {
        handleError(e, s);
      }
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to fetch store');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[FoodStore] getMyStore completed');
    }
  }

  Future<void> getMyStoreRequest() async {
    devtools.log('[FoodStore] Starting getMyStoreRequest');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();
      devtools.log('[FoodStore] Fetching store request data');

      final response = await _apiClient.get(
        ApiEndpoints.sellerFoodStoreVerificationRequests,
      );

      if (response.data['data'] is List && response.data['data'].isEmpty) {
        _storeRequest = null;
        return;
      }

      final storeRequests =
          (response.data['data'] as List)
              .map((item) => VerificationRequest.fromMap(item))
              .toList();

      final filteredList =
          storeRequests
              .where((request) => request.foodStoreId == _currentStore?.id)
              .toList();
      if (filteredList.isEmpty) {
        _storeRequest = null;
        return;
      }
      _storeRequest = filteredList.first;
      devtools.log('[FoodStore] Store data parsed successfully');
    } on ApiException catch (e, s) {
      if (e.statusCode == 404 || e.statusCode == 400) {
        _storeRequest = null;

        clearError();
      } else {
        handleError(e, s);
      }
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to fetch store request');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[FoodStore] getMyStoreRequest completed');
    }
  }

  Future<void> createStore({
    required String name,
    required XFile? imageFile,
    String? description,
    required Map<String, dynamic>? location,
  }) async {
    devtools.log('[FoodStore] Starting createStore');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();

      final formData = FormData.fromMap({
        'name': name,
        'description': description ?? '',
        'location': location,
        if (imageFile != null)
          'profileImage': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'store_profile.jpg',
          ),
      });

      final response = await _apiClient.postMultipart(
        ApiEndpoints.sellerFoodStore,
        formData,
      );

      _currentStore = FoodStore.fromJson(response.data);
      devtools.log('[FoodStore] Store created successfully');
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to create store');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[FoodStore] createStore completed');
    }
  }

  Future<void> updateStore({
    String? description,
    double? latitude,
    double? longitude,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? additionalDetails,
  }) async {
    devtools.log('[FoodStore] Starting updateStore');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();

      final data = {
        'description': description ?? _currentStore?.description ?? '',
        'location': {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'street': street ?? _currentStore?.address?.street ?? '',
          'city': city ?? _currentStore?.address?.city ?? '',
          'state': state ?? _currentStore?.address?.state ?? '',
          'zipCode': zipCode ?? _currentStore?.address?.zipCode ?? '',
          'country': country ?? _currentStore?.address?.country ?? '',
          'additionalDetails':
              additionalDetails ??
              _currentStore?.address?.additionalDetails ??
              '',
        },
      };

      final response = await _apiClient.patch(
        ApiEndpoints.sellerFoodStore,
        body: data,
      );

      _currentStore = FoodStore.fromJson(response.data);
      devtools.log('[FoodStore] Store updated successfully');
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to update store');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[FoodStore] updateStore completed');
    }
  }

  Future<void> updateProfileImage(XFile imageFile) async {
    devtools.log('[FoodStore] Starting updateProfileImage');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();

      devtools.log('[FoodStore] Uploading image: ${imageFile.path}');
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'store_profile.jpg',
        ),
      });

      final response = await _apiClient.postMultipart(
        ApiEndpoints.sellerFoodStoreProfileImage,
        formData,
      );

      _currentStore = FoodStore.fromJson(response.data);
      devtools.log('[FoodStore] Profile image updated successfully');
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to update profile image');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[FoodStore] updateProfileImage completed');
    }
  }

  Future<void> acceptVendorAgreement() async {
    devtools.log('[FoodStore] Accepting vendor agreement');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.sellerVendorAgreementAccept,
      );

      if (response.data != null) {
        _currentStore = FoodStore.fromJson(response.data);
      } else {
        await getMyStore();
      }

      devtools.log('[FoodStore] Vendor agreement accepted successfully');
    } on DioException catch (e, s) {
      final status = e.response?.statusCode;
      // Route not deployed yet (404) or network unavailable — save locally
      if (status == 404 || e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        devtools.log('[FoodStore] Vendor agreement API unavailable — saving locally (demo mode)');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('vendorContractSigned', true);
        await prefs.setString(
          'contractSignedAt',
          DateTime.now().toIso8601String(),
        );
        // Clear any lingering error so the UI navigates forward
        clearError();
      } else {
        handleError(e, s, fallbackMessage: 'Failed to accept vendor agreement');
      }
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to accept vendor agreement');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns true if the vendor has signed the agreement —
  /// either confirmed by the server or saved locally in demo mode.
  Future<bool> hasVendorContractSigned() async {
    // _currentStore doesn't expose hasSignedVendorContract yet — rely on prefs only
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vendorContractSigned') ?? false;
  }

  Future<void> createFoodStoreVerificationRequest(List<File?> files) async {
    devtools.log('[FoodStore] Starting document upload for verification');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();
      devtools.log('[FoodStore] Uploading ${files.length} documents');

      final formData = FormData();
      formData.files.addAll(
        await Future.wait(
          files.where((x) => x != null).map((file) async {
            final extension = file!.path.split('.').last;
            return MapEntry(
              'documents[]',
              await MultipartFile.fromFile(
                file.path,
                filename:
                    '${_currentStore!.name}-doc-${DateTime.now().millisecondsSinceEpoch}.$extension',
              ),
            );
          }),
        ),
      );
      final response = await _apiClient.postMultipart(
        ApiEndpoints.sellerFoodStoreVerificationRequests,
        formData,
      );

      _storeRequest = VerificationRequest.fromMap(response.data);
      devtools.log('[FoodStore] Verification request created successfully');
    } catch (e, s) {
      handleError(
        e,
        s,
        fallbackMessage: 'Failed to create verification request',
      );
      _isLoading = false;
      notifyListeners();
      devtools.log('[FoodStore] createFoodStoreVerificationRequest completed');
    }
  }

  Future<void> deleteStore() async {
    devtools.log('[FoodStore] Starting deleteStore');
    try {
      _verifySeller();
      _isLoading = true;
      clearError();
      notifyListeners();

      devtools.log('[FoodStore] Deleting store ID: ${_currentStore?.id}');
      await _apiClient.delete(ApiEndpoints.sellerFoodStore);

      _currentStore = null;
      devtools.log('[FoodStore] Store deleted successfully');
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to delete store');
    } finally {
      _isLoading = false;
      notifyListeners();
      devtools.log('[FoodStore] deleteStore completed');
    }
  }

  final List<FoodStore> _foodStores = [];
  final List<FoodStore> _nearbyFoodStores = [];
  bool _isNearbyLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 50;

  String _search = '';
  String? _country;
  String? _city;
  String? _state;
  String? _zipCode;
  String _sortBy = 'createdAt';
  String _sortOrder = 'DESC';

  double? _latitude;
  double? _longitude;
  double _radiusKm = 10.0;

  List<FoodStore> get foodStores => _foodStores;
  List<FoodStore> get nearbyFoodStores => _nearbyFoodStores;
  bool get isNearbyLoading => _isNearbyLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get canLoadMore => _currentPage < _totalPages;

  Future<void> fetchFoodStores({
    bool refresh = false,
    bool hasDishes = false,
  }) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      if (refresh) {
        _currentPage = 1;
        _foodStores.clear();
      }

      final response = await _apiClient.get(
        ApiEndpoints.buyerFoodStores,
        queryParameters: {
          'page': _currentPage,
          'limit': _limit,
          'sortBy': _sortBy,
          'sortOrder': _sortOrder,
          'search': _search.isNotEmpty ? _search : null,
          'country': _country,
          'city': _city,
          'state': _state,
          'zipCode': _zipCode,
          'hasDishes': hasDishes,
        },
      );

      _handleResponse(response);
      devtools.log('[FoodStores] Fetched page $_currentPage');
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to load food stores');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyFoodStores() async {
    if (_isNearbyLoading || _latitude == null || _longitude == null) return;

    try {
      _isNearbyLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.get(
        ApiEndpoints.buyerFoodStoresNearby,
        queryParameters: {
          'latitude': _latitude,
          'longitude': _longitude,
          'radiusKm': _radiusKm,
          'limit': _limit,
        },
      );
      final newStores =
          (response.data as List)
              .map((item) => FoodStore.fromJson(item as Map<String, dynamic>))
              .toList();

      _nearbyFoodStores.addAll(newStores);
      devtools.log('[FoodStores] Fetched nearby stores');
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to load nearby food stores',
      );
    } finally {
      _isNearbyLoading = false;
      notifyListeners();
    }
  }

  void setFilters({
    String? search,
    String? country,
    String? city,
    String? state,
    String? zipCode,
  }) {
    _search = search?.trim() ?? '';
    _country = country?.trim();
    _city = city?.trim();
    _state = state?.trim();
    _zipCode = zipCode?.trim();
    _resetPaginationAndFetch();
  }

  void setLocationForNearbySearch(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  void setRadius(double radiusKm) {
    _radiusKm = radiusKm.clamp(0.1, 100.0);
  }

  void setSorting({String? sortBy, String? sortOrder}) {
    _sortBy = sortBy?.trim() ?? 'createdAt';
    _sortOrder = (sortOrder?.toUpperCase() == 'ASC') ? 'ASC' : 'DESC';
    _resetPaginationAndFetch();
  }

  Future<void> loadMore() async {
    if (!canLoadMore || _isLoading) return;
    _currentPage++;
    await fetchFoodStores();
  }

  void _resetPaginationAndFetch() {
    _currentPage = 1;
    _foodStores.clear();
    fetchFoodStores();
  }

  void _handleResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      _validateResponseStructure(data);

      final newStores =
          (data['data'] as List)
              .map((item) => FoodStore.fromJson(item as Map<String, dynamic>))
              .toList();

      _foodStores.addAll(newStores);
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
      throw const FormatException('Invalid food stores response structure');
    }
  }

  void _updatePagination(Map<String, dynamic> data) {
    _currentPage = data['current_page'] as int;
    _totalPages = data['total_pages'] as int;
    _totalItems = data['total_items'] as int;
    _limit = data['limit'] as int;
  }

  FoodStore? _selectedFoodStore;
  bool _isDetailLoading = false;
  String? _detailError;

  final List<Dish> _foodStoreDishes = [];
  int _dishesCurrentPage = 1;
  int _dishesTotalPages = 1;
  int _dishesTotalItems = 0;
  bool _dishesLoading = false;
  String? _dishesError;

  String _dishesSearch = '';
  double? _minPrice;
  double? _maxPrice;
  List<String> _ingredients = [];
  List<String> _categories = [];
  String _dishesSortBy = 'createdAt';
  String _dishesSortOrder = 'DESC';

  FoodStore? get selectedFoodStore => _selectedFoodStore;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  List<Dish> get foodStoreDishes => _foodStoreDishes;
  bool get dishesLoading => _dishesLoading;
  String? get dishesError => _dishesError;
  bool get canLoadMoreDishes => _dishesCurrentPage < _dishesTotalPages;

  Future<void> getFoodStoreById(String id) async {
    try {
      _isDetailLoading = true;
      _detailError = null;
      notifyListeners();

      final response = await _apiClient.get(ApiEndpoints.buyerFoodStore(id));

      _selectedFoodStore = FoodStore.fromJson(response.data);
    } on ApiException catch (e) {
      _detailError = e.message;
      devtools.log('[FoodStore] API error: ${e.message}', error: e);
    } catch (e, stackTrace) {
      _detailError = 'An unexpected error occurred';
      devtools.log('[FoodStore] Error: $e', error: e, stackTrace: stackTrace);
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFoodStoreDishes(
    String foodStoreId, {
    bool refresh = false,
  }) async {
    if (_dishesLoading) return;

    try {
      _dishesLoading = true;
      _dishesError = null;
      notifyListeners();

      if (refresh) {
        _dishesCurrentPage = 1;
        _foodStoreDishes.clear();
      }

      final response = await _apiClient.get(
        ApiEndpoints.buyerFoodStoreDishes(foodStoreId),
      );

      _handleDishesResponse(response);
      devtools.log('[FoodStoreDishes] Fetched page $_dishesCurrentPage');
    } on ApiException catch (e) {
      _dishesError = e.message;
      devtools.log('[FoodStoreDishes] API error: ${e.message}', error: e);
    } catch (e, stackTrace) {
      _dishesError = 'An unexpected error occurred';
      devtools.log(
        '[FoodStoreDishes] Error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _dishesLoading = false;
      notifyListeners();
    }
  }

  void setDishFilters({
    String? search,
    double? minPrice,
    double? maxPrice,
    List<String>? ingredients,
    List<String>? categories,
    String? sortBy,
    String? sortOrder,
  }) {
    _dishesSearch = search ?? _dishesSearch;
    _minPrice = minPrice ?? 0;
    _maxPrice = maxPrice;
    _ingredients = ingredients ?? _ingredients;
    _categories = categories ?? _categories;
    _dishesSortBy = sortBy ?? _dishesSortBy;
    _dishesSortOrder = (sortOrder?.toUpperCase() == 'ASC') ? 'ASC' : 'DESC';
    _resetDishesPaginationAndFetch();
  }

  Future<void> loadMoreDishes(String foodStoreId) async {
    if (!canLoadMoreDishes || _dishesLoading) return;
    _dishesCurrentPage++;
    await fetchFoodStoreDishes(foodStoreId);
  }

  void _handleDishesResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      _validateDishesResponseStructure(data);

      final newDishes =
          (data['data'] as List)
              .map((item) => Dish.fromMap(item as Map<String, dynamic>))
              .toList();
      _foodStoreDishes.clear();
      _foodStoreDishes.addAll(newDishes);
      _updateDishesPagination(data);
    } else {
      throw ApiFailure(
        'Unexpected status code: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  void _validateDishesResponseStructure(Map<String, dynamic> data) {
    final requiredKeys = {
      'current_page',
      'limit',
      'total_items',
      'total_pages',
      'data',
    };
    if (!requiredKeys.every(data.containsKey)) {
      throw const FormatException('Invalid dishes response structure');
    }
  }

  void _updateDishesPagination(Map<String, dynamic> data) {
    _dishesCurrentPage = data['current_page'] as int;
    _dishesTotalPages = data['total_pages'] as int;
    _dishesTotalItems = data['total_items'] as int;
  }

  void _resetDishesPaginationAndFetch() {
    _dishesCurrentPage = 1;
    _foodStoreDishes.clear();
    if (_selectedFoodStore != null) {
      fetchFoodStoreDishes(_selectedFoodStore!.id);
    }
  }

  void clearSelectedFoodStore() {
    _selectedFoodStore = null;
    _dishesCurrentPage = 1;
    _dishesTotalPages = 1;
    _dishesTotalItems = 0;
    notifyListeners();
  }

  void clearFoodStoreSelection() {
    _selectedFoodStore = null;
    _foodStoreDishes.clear();
    _dishesCurrentPage = 1;
    _dishesTotalPages = 1;
    _dishesTotalItems = 0;
    notifyListeners();
  }
}
