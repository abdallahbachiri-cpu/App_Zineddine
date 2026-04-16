import 'dart:developer' as devtools;

import 'package:cuisinous/core/mixins/error_handling_mixin.dart';
import 'package:cuisinous/data/models/dish_ingredient.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:flutter/foundation.dart';

import '../services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

class DishIngredientsProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;
  DishIngredientsProvider({required ApiClient apiClient})
    : _apiClient = apiClient;

  final SellerDishProvider _dishProvider = getIt<SellerDishProvider>();

  final List<DishIngredient> _dishIngredients = [];
  bool _isDishLoading = false;

  List<DishIngredient> get dishIngredients => _dishIngredients;
  bool get isDishLoading => _isDishLoading;
  String? get dishError => error;

  Future<void> fetchDishIngredients(String dishId) async {
    if (_isDishLoading) return;

    try {
      _isDishLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.get(
        ApiEndpoints.sellerDishIngredients(dishId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        _dishIngredients.clear();
        _dishIngredients.addAll(
          data.map(
            (item) => DishIngredient.fromMap(item as Map<String, dynamic>),
          ),
        );
        devtools.log('[DishIngredients] Fetched ingredients for dish $dishId');
      }
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to fetch ingredients',
      );
    } finally {
      _isDishLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDishIngredient({
    required String dishId,
    required String ingredientId,
    required double price,
    required bool isSupplement,
  }) async {
    try {
      _isDishLoading = true;
      clearError();
      notifyListeners();

      final body = {
        'ingredientId': ingredientId,
        'price': price,
        'isSupplement': isSupplement,
      };

      final response = await _apiClient.post(
        ApiEndpoints.sellerDishIngredients(dishId),
        body: body,
      );

      if (response.statusCode == 201) {
        final newIngredient = DishIngredient.fromMap(
          response.data as Map<String, dynamic>,
        );
        _dishIngredients.add(newIngredient);
        _dishProvider.updateSelectedDishIngredients(newIngredient, true);
        devtools.log('[DishIngredients] Added ingredient to dish $dishId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to add ingredient');
    } finally {
      _isDishLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDishIngredient({
    required String dishId,
    required String ingredientId,
    required double price,
    required bool isSupplement,
    required bool available,
  }) async {
    try {
      _isDishLoading = true;
      clearError();
      notifyListeners();

      final body = {
        'price': price,
        'isSupplement': isSupplement,
        'available': available,
      };

      final response = await _apiClient.patch(
        ApiEndpoints.sellerDishIngredient(dishId, ingredientId),
        body: body,
      );

      if (response.statusCode == 200) {
        final updatedIngredient = DishIngredient.fromMap(
          response.data as Map<String, dynamic>,
        );
        final index = _dishIngredients.indexWhere(
          (ing) => ing.id == updatedIngredient.id,
        );
        _dishProvider.updateSelectedDishIngredients(updatedIngredient, null);
        if (index != -1) _dishIngredients[index] = updatedIngredient;
        devtools.log('[DishIngredients] Updated ingredient in dish $dishId');
      }
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to update ingredient',
      );
    } finally {
      _isDishLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeDishIngredient({
    required String dishId,
    required String ingredientId,
  }) async {
    try {
      _isDishLoading = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.delete(
        ApiEndpoints.sellerDishIngredient(dishId, ingredientId),
      );

      if (response.statusCode == 204) {
        _dishProvider.updateSelectedDishIngredients(
          _dishIngredients.firstWhere(
            (ing) => ing.ingredientId == ingredientId,
          ),
          false,
        );
        _dishIngredients.removeWhere((ing) => ing.ingredientId == ingredientId);
        devtools.log('[DishIngredients] Removed ingredient from dish $dishId');
      }
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to remove ingredient',
      );
    } finally {
      _isDishLoading = false;
      notifyListeners();
    }
  }

  void clearDishIngredients() {
    _dishIngredients.clear();
    clearError();
    notifyListeners();
  }

  void clearDishError() {
    clearError();
  }

  void updateSortedIngredients(List<DishIngredient> sortedIngredients) {
    _dishIngredients.clear();
    _dishIngredients.addAll(sortedIngredients);
    notifyListeners();
  }
}
