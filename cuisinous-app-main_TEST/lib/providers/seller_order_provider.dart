import 'dart:developer' as devtools;

import 'package:cuisinous/data/models/buyer_order.dart';
import 'package:cuisinous/data/models/full_buyer_order.dart';
import 'package:cuisinous/data/models/proxy_call_numbers.dart';

import 'package:flutter/foundation.dart';
import 'package:cuisinous/core/enums/order_enums.dart';
import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/core/mixins/error_handling_mixin.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import '../core/ui/view_state.dart';

class SellerOrderProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;

  SellerOrderProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  final List<SmallOrder> _orders = [];
  FullOrder? _selectedOrder;
  ViewState _viewState = ViewState.initial;
  bool _isProcessing = false;
  bool _isProxyCallLoading = false;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  String _search = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'DESC';
  double? _minPrice;
  double? _maxPrice;
  String? _buyerId;
  String? _status;
  String? _paymentStatus;
  String? _deliveryStatus;

  List<SmallOrder> get orders => _orders;
  FullOrder? get selectedOrder => _selectedOrder;
  ViewState get viewState => _viewState;
  bool get isLoading => _viewState == ViewState.loading;
  bool get isProcessing => _isProcessing;
  bool get isProxyCallLoading => _isProxyCallLoading;
  bool get canLoadMore => _currentPage < _totalPages;
  int get totalItems => _totalItems;

  String get search => _search;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get buyerId => _buyerId;
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

  Future<void> fetchOrders({
    int page = 1,
    bool resetFilters = false,
    bool silent = false,
  }) async {
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

        'sortBy': _sortBy,
        'sortOrder': _sortOrder,
        if (_search.isNotEmpty) 'search': _search,
        if (_minPrice != null) 'minPrice': _minPrice,
        if (_maxPrice != null) 'maxPrice': _maxPrice,
        if (_buyerId != null) 'buyerId': _buyerId,
        if (_status != null) 'status': _status,
        if (_paymentStatus != null) 'paymentStatus': _paymentStatus,
        if (_deliveryStatus != null) 'deliveryStatus': _deliveryStatus,
      };

      final response = await _apiClient.get(
        ApiEndpoints.sellerOrders,
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
      handleError(e, stackTrace, fallbackMessage: 'Failed to fetch orders');
    }
    notifyListeners();
  }

  Future<void> getOrderById(String id) async {
    _viewState = ViewState.loading;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.sellerOrder(id));

      if (response.statusCode == 200) {
        _selectedOrder = FullOrder.fromMap(response.data);
        _viewState = ViewState.success;
        devtools.log('[Orders] Fetched order $id');
      }
    } catch (e, stackTrace) {
      _viewState = ViewState.error;
      handleError(e, stackTrace, fallbackMessage: 'Failed to fetch order');
    }
    notifyListeners();
  }

  Future<ProxyCallNumbers> fetchProxyNumbers(String orderId) async {
    _isProxyCallLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        ApiEndpoints.sellerOrderProxyNumbers(orderId),
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return ProxyCallNumbers.fromMap(data);
      }

      devtools.log(
        '[Orders] Unexpected proxy response: ${response.statusCode} ${response.data.runtimeType}',
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

  Future<void> confirmOrder(String orderId) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.sellerOrderConfirm(orderId),
      );

      if (response.statusCode == 200) {
        _updateOrderStatus(orderId, status: OrderStatus.confirmed);
        devtools.log('[Orders] Confirmed order $orderId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to confirm order');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> markOrderAsReady(String orderId) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.sellerOrderMarkAsReady(orderId),
      );

      if (response.statusCode == 200) {
        _updateOrderStatus(orderId, status: OrderStatus.confirmed);
        devtools.log('[Orders] Confirmed order $orderId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to confirm order');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.sellerOrderCancel(orderId),
      );

      if (response.statusCode == 200) {
        _updateOrderStatus(orderId, status: OrderStatus.cancelled);
        devtools.log('[Orders] Cancelled order $orderId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to cancel order');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> confirmDelivery(String orderId, String confirmationCode) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final response = await _apiClient.post(
        ApiEndpoints.sellerOrderConfirmDelivery(orderId),
        body: {'confirmationCode': confirmationCode},
      );

      if (response.statusCode == 200) {
        _updateOrderStatus(
          orderId,
          status: OrderStatus.completed,
          deliveryStatus: OrderDeliveryStatus.delivered,
        );
        devtools.log('[Orders] Confirmed delivery for order $orderId');
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Failed to confirm delivery');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void _updateOrderStatus(
    String orderId, {
    OrderStatus? status,
    OrderDeliveryStatus? deliveryStatus,
    OrderPaymentStatus? paymentStatus,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: status?.name,
        deliveryStatus: deliveryStatus?.name,
        paymentStatus: paymentStatus?.name,
      );
    }

    if (_selectedOrder?.id == orderId) {
      _selectedOrder = _selectedOrder!.copyWith(
        status: status?.name,
        deliveryStatus: deliveryStatus?.name,
        paymentStatus: paymentStatus?.name,
      );
    }
    notifyListeners();
  }

  Future<void> loadMoreOrders() async {
    if (!canLoadMore || _viewState == ViewState.loading) return;
    _currentPage++;
    await fetchOrders(page: _currentPage);
  }

  void setFilters({
    String? search,
    double? minPrice,
    double? maxPrice,
    String? buyerId,
    String? status,
    String? paymentStatus,
    String? deliveryStatus,
    String? sortBy,
    String? sortOrder,
  }) {
    _search = search ?? _search;
    _minPrice = minPrice ?? _minPrice;
    _maxPrice = maxPrice ?? _maxPrice;
    _buyerId = buyerId ?? _buyerId;
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
    _buyerId = null;
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
