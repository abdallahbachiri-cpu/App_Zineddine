import 'dart:developer' as devtools;

import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:cuisinous/core/mixins/error_handling_mixin.dart';
import 'package:cuisinous/data/models/allergen.dart';
import 'package:cuisinous/data/models/dish_allergen.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:flutter/material.dart';

class SellerAllergenProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;
  SellerAllergenProvider({required ApiClient apiClient})
    : _apiClient = apiClient;

  final SellerDishProvider _dishProvider = getIt<SellerDishProvider>();

  final List<Allergen> _allergens = [];
  bool _isLoading = false;

  List<Allergen> get allergens => _allergens;
  bool get isLoading => _isLoading;

  Future<void> getAllergens({String? query}) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.get(
        ApiEndpoints.sellerAllergens,
        queryParameters: query != null ? {'search': query} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        _allergens.clear();
        _allergens.addAll(
          data.map((item) => Allergen.fromMap(item as Map<String, dynamic>)),
        );
        devtools.log('[SellerAllergen] Fetched allergens');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to fetch allergens');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAllergenToDish(
    String dishId,
    String allergenId, {
    String? specification,
  }) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      final body = {
        'allergenId': allergenId,
        if (specification != null) 'specification': specification,
      };

      final response = await _apiClient.post(
        ApiEndpoints.sellerDishAllergens(dishId),
        body: body,
      );

      if (response.statusCode == 201) {
        final newAllergen = DishAllergen.fromMap(
          response.data as Map<String, dynamic>,
        );
        _dishProvider.updateSelectedDishAllergens(newAllergen);
        devtools.log('[SellerAllergen] Added allergen to dish $dishId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to add allergen');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeAllergenFromDish(String dishId, String allergenId) async {
    try {
      _isLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.delete(
        ApiEndpoints.sellerDishAllergen(dishId, allergenId),
      );

      if (response.statusCode == 204) {
        _dishProvider.removeSelectedDishAllergen(allergenId);
        devtools.log(
          '[SellerAllergen] Removed allergen $allergenId from dish $dishId',
        );
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to remove allergen');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
