import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/data/models/buyer_order.dart';
import 'package:cuisinous/data/models/full_buyer_order.dart';
import 'package:cuisinous/core/enums/order_enums.dart';
import 'package:cuisinous/data/models/proxy_call_numbers.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

import 'package:flutter/material.dart';

import 'dart:developer' as devtools;

import '../core/mixins/error_handling_mixin.dart';
import '../core/ui/view_state.dart';

class BuyerOrderProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;

  BuyerOrderProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  final List<SmallOrder> _orders = [];
  final List<SmallOrder> _newOrders = [];
  FullOrder? _selectedOrder;
  ViewState _viewState = ViewState.initial;
  bool _isProcessing = false;
  bool _isProxyCallLoading = false;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 20;

  String _search = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'DESC';
  double? _minPrice;
  double? _maxPrice;
  String? _foodStoreId;
  String? _status;
  String? _paymentStatus;
  String? _deliveryStatus;

  List<SmallOrder> get orders => _orders;
  List<SmallOrder> get newOrders => _newOrders;
  FullOrder? get selectedOrder => _selectedOrder;
  ViewState get viewState => _viewState;
  bool get isLoading => _viewState == ViewState.loading;
  bool get isProcessing => _isProcessing;
  bool get isProxyCallLoading => _isProxyCallLoading;
  bool get canLoadMore => _currentPage < _totalPages;
  int get currentPage => _currentPage;

  String get search => _search;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get foodStoreId => _foodStoreId;
  String? get status => _status;
  String? get paymentStatus => _paymentStatus;
  String? get deliveryStatus => _deliveryStatus;

  bool get hasActiveFilters {
    return _search.isNotEmpty ||
        _minPrice != null ||
        _maxPrice != null ||
        _status != null ||
        _paymentStatus != null ||
        _deliveryStatus != null ||
        _sortBy != 'createdAt' ||
        _sortOrder != 'DESC';
  }

  Future<void> checkout(String? locationId) async {
    try {
      _isProcessing = true;
      final response = await _apiClient.post(
        ApiEndpoints.buyerCartCheckout,
        body: {
          if (locationId != null) 'locationId': locationId,
          'deliveryMethod': locationId != null ? 'delivery' : 'pickup',
        },
      );

      if (response.statusCode == 200) {
        _newOrders.clear();
        final checkoutOrders =
            (response.data as List)
                .map((order) => SmallOrder.fromMap(order))
                .toList();
        _newOrders.addAll(checkoutOrders);
        _orders.insertAll(0, checkoutOrders);
        devtools.log(
          '[Orders] Checkout successful with ${checkoutOrders.length} orders',
        );
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Checkout failed');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderNote(String orderId, String note) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.buyerOrderNote(orderId),
        body: {'note': note},
      );

      if (response.statusCode == 200) {
        final updatedOrder = FullOrder.fromMap(response.data);

        if (_selectedOrder?.id == orderId) {
          _selectedOrder!.copyWith(buyerNote: updatedOrder.buyerNote);
        }
        notifyListeners();
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to update note');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders({
    int page = 1,
    bool resetFilters = false,
    bool silent = false,
  }) async {
    devtools.log('BuyerOrderProvider: fetchOrders called. Silent: $silent');
    if (resetFilters) {
      _resetFilters();
    }

    if (!silent) {
      _viewState = ViewState.loading;
      notifyListeners();
    }

    try {
      final queryParams = {
        'page': page,
        'limit': _limit,
        'sortBy': _sortBy,
        'sortOrder': _sortOrder,
        if (_search.isNotEmpty) 'search': _search,
        if (_minPrice != null) 'minPrice': _minPrice,
        if (_maxPrice != null) 'maxPrice': _maxPrice,
        if (_foodStoreId != null) 'foodStoreId': _foodStoreId,
        if (_status != null) 'status': _status,
        if (_paymentStatus != null) 'paymentStatus': _paymentStatus,
        if (_deliveryStatus != null) 'deliveryStatus': _deliveryStatus,
      };

      final response = await _apiClient.get(
        ApiEndpoints.buyerOrders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _currentPage = data['current_page'];
        _totalPages = data['total_pages'];
        _totalItems = data['total_items'];

        if (page == 1) _orders.clear();
        _orders.addAll(
          (data['data'] as List).map((item) => SmallOrder.fromMap(item)),
        );
        _viewState = ViewState.success;
        devtools.log('[Orders] Fetched ${_orders.length} orders');
      }
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to load orders');
    }
    notifyListeners();
  }

  Future<void> getOrderById(String id) async {
    _viewState = ViewState.loading;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.buyerOrder(id));

      if (response.statusCode == 200) {
        _selectedOrder = FullOrder.fromMap(response.data);
        _viewState = ViewState.success;
        devtools.log('[Orders] Fetched order $id');
      }
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to load order');
    }
    notifyListeners();
  }

  Future<ProxyCallNumbers> fetchProxyNumbers(String orderId) async {
    _isProxyCallLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        ApiEndpoints.buyerOrderProxyNumbers(orderId),
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return ProxyCallNumbers.fromMap(data);
      }

      devtools.log(
        '[Orders] Unexpected proxy call response: ${response.statusCode} ${response.data.runtimeType}',
      );
      throw ApiFailure('Invalid response from server', response.statusCode);
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Unable to fetch proxy numbers',
      );
      rethrow;
    } finally {
      _isProxyCallLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> payOrder(String orderId) async {
    try {
      _isProcessing = true;
      final response = await _apiClient.post(
        ApiEndpoints.buyerOrderPay(orderId),
      );
      devtools.log('[Orders] respose: ${response.data}');
      return response.data;
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Payment failed');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> orderPay(String orderId) async {
    try {
      _isProcessing = true;
      final response = await _apiClient.post(
        ApiEndpoints.buyerOrderPay(orderId),
      );

      if (response.statusCode == 200) {
        _updateOrderStatus(orderId, paymentStatus: OrderPaymentStatus.paid);
        devtools.log('[Orders] Paid order $orderId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Payment failed');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      _isProcessing = true;
      final response = await _apiClient.post(
        ApiEndpoints.buyerOrderCancel(orderId),
      );

      if (response.statusCode == 200) {
        _updateOrderStatus(orderId, status: OrderStatus.cancelled);
        devtools.log('[Orders] Cancelled order $orderId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Cancel failed');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void _updateOrderStatus(
    String orderId, {
    OrderStatus? status,
    OrderPaymentStatus? paymentStatus,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: status?.name ?? _orders[index].status,
        paymentStatus: paymentStatus?.name ?? _orders[index].paymentStatus,
      );
    }

    if (_selectedOrder?.id == orderId) {
      _selectedOrder = _selectedOrder!.copyWith(
        status: status?.name ?? _selectedOrder!.status,
        paymentStatus: paymentStatus?.name ?? _selectedOrder!.paymentStatus,
      );
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> addTipToOrder(
    String orderId,
    double tipAmount,
  ) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.buyerOrderTip(orderId),
        body: {'tip': tipAmount},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ApiFailure(
          response.data['message'] ?? 'Failed to initiate tip',
          response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to initiate tip');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreOrders() async {
    if (!canLoadMore || _viewState == ViewState.loading) return;
    _currentPage++;
    await fetchOrders(page: _currentPage);
  }

  Future<void> refreshOrders({bool silent = true}) async {
    await fetchOrders(page: _currentPage, silent: silent);
  }

  void setFilters({
    String? search,
    double? minPrice,
    double? maxPrice,
    String? foodStoreId,
    String? status,
    String? paymentStatus,
    String? deliveryStatus,
    String? sortBy,
    String? sortOrder,
  }) {
    _search = search ?? _search;
    _minPrice = minPrice ?? _minPrice;
    _maxPrice = maxPrice ?? _maxPrice;
    _foodStoreId = foodStoreId ?? _foodStoreId;
    _status = status ?? _status;
    _paymentStatus = paymentStatus ?? _paymentStatus;
    _deliveryStatus = deliveryStatus ?? _deliveryStatus;
    _sortBy = sortBy ?? _sortBy;
    _sortOrder = sortOrder ?? _sortOrder;
    _currentPage = 1;
    fetchOrders(page: 1);
  }

  void _resetFilters() {
    _search = '';
    _minPrice = null;
    _maxPrice = null;
    _foodStoreId = null;
    _status = null;
    _paymentStatus = null;
    _deliveryStatus = null;
    _sortBy = 'createdAt';
    _sortOrder = 'DESC';
  }

  void clearSelection() {
    _selectedOrder = null;
    notifyListeners();
  }
}
