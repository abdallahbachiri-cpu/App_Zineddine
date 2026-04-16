import 'dart:async';
import 'dart:developer' as devtools;

import 'package:cuisinous/data/models/cart.dart';
import 'package:cuisinous/data/models/cart_dish.dart';
import 'package:cuisinous/data/models/cart_dish_ingredient.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

import 'package:flutter/material.dart';

import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/services/network/api_client_service.dart';

import '../core/mixins/error_handling_mixin.dart';
import '../core/ui/view_state.dart';

class CartProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;
  static const int MAX_DISH_QUANTITY = 10;
  static const int MAX_INGREDIENT_QUANTITY = 5;

  CartProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  Cart? _cart;
  ViewState _viewState = ViewState.initial;
  bool _isProcessing = false;

  final Map<String, Timer> _dishDebounceTimers = {};
  final Map<String, Timer> _ingredientDebounceTimers = {};
  final Map<String, Cart> _preDebounceCartStates = {};

  Cart? get cart => _cart;
  ViewState get viewState => _viewState;
  bool get isLoading => _viewState == ViewState.loading;
  bool get isProcessing => _isProcessing;

  Future<void> fetchCart({bool silent = false}) async {
    if (!silent) {
      _viewState = ViewState.loading;
      notifyListeners();
    }
    clearError();

    try {
      final response = await _apiClient.get(ApiEndpoints.buyerCart);

      if (response.statusCode == 200) {
        _cart = Cart.fromMap(response.data);
        devtools.log('[Cart] Fetched cart with ${_cart?.dishes.length} items');
      }
      _viewState = ViewState.success;
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to load cart');
    }
    notifyListeners();
  }

  Future<void> addDishToCart(String dishId, int quantity) async {
    try {
      if (quantity < 1 || quantity > MAX_DISH_QUANTITY) {
        throw ApiFailure(
          'Quantity must be between 1 and $MAX_DISH_QUANTITY',
          400,
        );
      }

      _isProcessing = true;
      clearError();
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.buyerCartDishes,
        body: {'dishId': dishId, 'quantity': quantity},
      );

      if (response.statusCode == 201) {
        await fetchCart();
        devtools.log('[Cart] Added dish $dishId (qty: $quantity)');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to add dish');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> updateDishQuantity(String cartDishId, int newQuantity) async {
    if (_cart == null) return;

    _dishDebounceTimers[cartDishId]?.cancel();

    final dishIndex = _cart!.dishes.indexWhere((d) => d.id == cartDishId);
    if (dishIndex == -1) return;

    if (!_preDebounceCartStates.containsKey(cartDishId)) {
      _preDebounceCartStates[cartDishId] = _cart!;
    }

    final oldDish = _cart!.dishes[dishIndex];
    final priceChange =
        (newQuantity - oldDish.quantity) * oldDish.dishUnitPrice;
    final newTotalPrice = _cart!.totalPrice + priceChange;

    final updatedDishes = List<CartDish>.from(_cart!.dishes);
    updatedDishes[dishIndex] = oldDish.copyWith(
      quantity: newQuantity,
      totalPrice: oldDish.dishUnitPrice * newQuantity,
    );

    _cart = _cart!.copyWith(dishes: updatedDishes, totalPrice: newTotalPrice);
    notifyListeners();

    _dishDebounceTimers[cartDishId] = Timer(
      const Duration(milliseconds: 800),
      () async {
        final cartStateForApiCall = _cart!;
        final originalCartState = _preDebounceCartStates.remove(cartDishId)!;

        try {
          _isProcessing = true;
          notifyListeners();

          final finalQuantity = cartStateForApiCall.dishes[dishIndex].quantity;

          await _apiClient.patch(
            ApiEndpoints.buyerCartDish(cartDishId),
            body: {'quantity': finalQuantity},
          );

          devtools.log(
            '[Cart] Debounced update for dish $cartDishId to quantity $finalQuantity successful.',
          );
          await fetchCart(silent: true);
        } catch (e, stackTrace) {
          _cart = originalCartState;
          handleError(e, stackTrace, fallbackMessage: 'Failed to update dish');
        } finally {
          _isProcessing = false;
          _dishDebounceTimers.remove(cartDishId);
          notifyListeners();
        }
      },
    );
  }

  Future<void> removeDishFromCart(String cartDishId) async {
    if (_cart == null || _isProcessing) return;

    final oldCart = _cart!;
    try {
      final dishToRemove = oldCart.dishes.firstWhere((d) => d.id == cartDishId);
      final newTotalPrice = oldCart.totalPrice - dishToRemove.totalPrice;

      final updatedDishes =
          oldCart.dishes.where((d) => d.id != cartDishId).toList();

      _cart = oldCart.copyWith(
        dishes: updatedDishes,
        totalPrice: newTotalPrice,
      );
      _isProcessing = true;
      clearError();
      notifyListeners();

      await _apiClient.delete(ApiEndpoints.buyerCartDish(cartDishId));

      devtools.log('[Cart] Removed dish $cartDishId');
      await fetchCart(silent: true);
    } catch (e, stackTrace) {
      _cart = oldCart;
      handleError(e, stackTrace, fallbackMessage: 'Failed to remove dish');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> addIngredientToDish({
    required String cartDishId,
    required String dishIngredientId,
    int quantity = 1,
  }) async {
    try {
      _isProcessing = true;
      notifyListeners();
      await _apiClient.post(
        ApiEndpoints.buyerCartDishIngredients(cartDishId),
        body: {'dishIngredientId': dishIngredientId, 'quantity': quantity},
      );
      await fetchCart();
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to add ingredient');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> updateIngredientQuantity({
    required String cartDishId,
    required String dishIngredientId,
    required int newQuantity,
  }) async {
    if (_cart == null) return;

    final compositeKey = '$cartDishId-$dishIngredientId';
    _ingredientDebounceTimers[compositeKey]?.cancel();

    if (!_preDebounceCartStates.containsKey(compositeKey)) {
      _preDebounceCartStates[compositeKey] = _cart!;
    }

    final dishIndex = _cart!.dishes.indexWhere((d) => d.id == cartDishId);
    if (dishIndex == -1) return;

    final oldDish = _cart!.dishes[dishIndex];
    final ingredientIndex = oldDish.ingredients.indexWhere(
      (i) => i.id == dishIngredientId,
    );
    if (ingredientIndex == -1) return;

    final oldIngredient = oldDish.ingredients[ingredientIndex];
    final priceChange =
        (newQuantity - oldIngredient.quantity) * oldIngredient.ingredient.price;

    final updatedIngredients = List<CartDishIngredient>.from(
      oldDish.ingredients,
    );
    updatedIngredients[ingredientIndex] = oldIngredient.copyWith(
      quantity: newQuantity,
    );

    final updatedDishes = List<CartDish>.from(_cart!.dishes);
    updatedDishes[dishIndex] = oldDish.copyWith(
      ingredients: updatedIngredients,
      totalPrice: oldDish.totalPrice + priceChange,
    );

    _cart = _cart!.copyWith(
      dishes: updatedDishes,
      totalPrice: _cart!.totalPrice + priceChange,
    );
    notifyListeners();

    _ingredientDebounceTimers[compositeKey] = Timer(
      const Duration(milliseconds: 800),
      () async {
        final cartStateForApiCall = _cart!;
        final originalCartState = _preDebounceCartStates.remove(compositeKey)!;

        try {
          _isProcessing = true;
          notifyListeners();

          final finalQuantity =
              cartStateForApiCall
                  .dishes[dishIndex]
                  .ingredients[ingredientIndex]
                  .quantity;

          await _apiClient.patch(
            ApiEndpoints.buyerCartDishIngredient(cartDishId, dishIngredientId),
            body: {'quantity': finalQuantity},
          );
          await fetchCart(silent: true);
        } catch (e, stackTrace) {
          _cart = originalCartState;
          handleError(
            e,
            stackTrace,
            fallbackMessage: 'Failed to update ingredient',
          );
        } finally {
          _isProcessing = false;
          _ingredientDebounceTimers.remove(compositeKey);
          notifyListeners();
        }
      },
    );
  }

  Future<void> removeIngredientFromDish({
    required String cartDishId,
    required String dishIngredientId,
  }) async {
    if (_cart == null || _isProcessing) return;

    final oldCart = _cart!;
    try {
      final dishIndex = oldCart.dishes.indexWhere((d) => d.id == cartDishId);
      if (dishIndex == -1) return;

      final oldDish = oldCart.dishes[dishIndex];
      final ingredientToRemove = oldDish.ingredients.firstWhere(
        (i) => i.id == dishIngredientId,
      );
      final priceOfIngredient =
          ingredientToRemove.ingredient.price * ingredientToRemove.quantity;

      final updatedIngredients =
          oldDish.ingredients.where((i) => i.id != dishIngredientId).toList();
      final updatedDishes = List<CartDish>.from(oldCart.dishes);
      updatedDishes[dishIndex] = oldDish.copyWith(
        ingredients: updatedIngredients,
        totalPrice: oldDish.totalPrice - priceOfIngredient,
      );

      _cart = oldCart.copyWith(
        dishes: updatedDishes,
        totalPrice: oldCart.totalPrice - priceOfIngredient,
      );
      _isProcessing = true;
      notifyListeners();

      await _apiClient.delete(
        ApiEndpoints.buyerCartDishIngredient(cartDishId, dishIngredientId),
      );
      await fetchCart(silent: true);
    } catch (e, stackTrace) {
      _cart = oldCart;
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Failed to remove ingredient',
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final timer in _dishDebounceTimers.values) {
      timer.cancel();
    }
    for (final timer in _ingredientDebounceTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
