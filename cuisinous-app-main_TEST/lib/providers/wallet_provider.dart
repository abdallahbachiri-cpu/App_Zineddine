import 'package:flutter/foundation.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as devtools;
import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

class WalletProvider with ChangeNotifier {
  final ApiClient _apiClient;
  WalletProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  Wallet? _wallet;
  bool _isWalletLoading = false;
  String? _walletError;
  final List<WalletTransaction> _transactions = [];
  bool _isTransactionsLoading = false;
  String? _transactionsError;
  int _currentPage = 1;
  int _totalPages = 1;

  Wallet? get wallet => _wallet;
  bool get isWalletLoading => _isWalletLoading;
  String? get walletError => _walletError;
  List<WalletTransaction> get transactions => _transactions;
  bool get isTransactionsLoading => _isTransactionsLoading;
  String? get transactionsError => _transactionsError;
  bool get canLoadMore => _currentPage < _totalPages;

  Future<void> fetchWallet() async {
    _isWalletLoading = true;
    _walletError = null;
    Future.microtask(notifyListeners);

    try {
      final response = await _apiClient.get(ApiEndpoints.sellerWallet);
      if (response.statusCode == 200) {
        _wallet = Wallet.fromMap(response.data);
      } else {
        throw ApiFailure('Failed to fetch wallet', response.statusCode);
      }
    } catch (e) {
      _walletError = 'An unexpected error occurred';
    } finally {
      _isWalletLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions({bool refresh = false}) async {
    devtools.log('=== FETCH TRANSACTIONS CALLED ===');
    devtools.log('Refresh: $refresh, Loading: $_isTransactionsLoading');

    if (_isTransactionsLoading && !refresh) {
      devtools.log('Already loading, skipping fetch');
      return;
    }

    _isTransactionsLoading = true;
    _transactionsError = null;
    if (refresh) {
      _currentPage = 1;
      _transactions.clear();
      devtools.log('Refreshing - cleared transactions, reset page to 1');
    }
    Future.microtask(notifyListeners);

    try {
      devtools.log(
        'Making API call to: api/seller/food-store/wallet/transactions',
      );
      devtools.log('Query params: page=$_currentPage, limit=10');

      final response = await _apiClient.get(
        ApiEndpoints.sellerWalletTransactions,
        queryParameters: {'page': _currentPage, 'limit': 10},
      );
      _handleTransactionsResponse(response);
    } catch (e) {
      devtools.log('Error fetching transactions: $e');
      devtools.log('Error type: ${e.runtimeType}');
      if (e is ApiFailure) {
        _transactionsError = 'Failed to load transactions: ${e.message}';
      } else {
        _transactionsError = 'An unexpected error occurred: ${e.toString()}';
      }
    } finally {
      _isTransactionsLoading = false;
      notifyListeners();
      devtools.log('=== FETCH TRANSACTIONS COMPLETED ===');
    }
  }

  void reset() {
    _wallet = null;
    _walletError = null;
    _transactions.clear();
    _transactionsError = null;
    _currentPage = 1;
    _totalPages = 1;
    Future.microtask(notifyListeners);
  }

  void _handleTransactionsResponse(Response response) {
    devtools.log('=== WALLET TRANSACTIONS RESPONSE DEBUG ===');
    devtools.log('Status Code: ${response.statusCode}');
    devtools.log('Response Data Type: ${response.data.runtimeType}');
    devtools.log('Response Data: ${response.data}');

    if (response.statusCode == 200) {
      if (response.data is List) {
        final items = response.data as List;
        devtools.log('Direct list response with ${items.length} items');
        devtools.log('Items content: $items');

        if (items.isNotEmpty) {
          _transactions.addAll(
            items.map((item) {
              devtools.log('Processing item: $item');
              return WalletTransaction.fromMap(item);
            }),
          );
          devtools.log(
            'Total transactions after adding: ${_transactions.length}',
          );
        } else {
          devtools.log('No items found in direct list response');
        }

        _currentPage = 1;
        _totalPages = 1;
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        devtools.log('Paginated response - Data keys: ${data.keys.toList()}');

        final items = data['data'] as List?;
        devtools.log('Items type: ${items.runtimeType}');
        devtools.log('Items length: ${items?.length ?? 'null'}');
        devtools.log('Items content: $items');

        if (items != null && items.isNotEmpty) {
          _transactions.addAll(
            items.map((item) {
              devtools.log('Processing item: $item');
              return WalletTransaction.fromMap(item);
            }),
          );
          devtools.log(
            'Total transactions after adding: ${_transactions.length}',
          );
        } else {
          devtools.log('No items found in paginated response');
        }

        _currentPage = data['current_page'] as int? ?? 1;
        _totalPages = data['total_pages'] as int? ?? 1;
        devtools.log(
          'Pagination - Current: $_currentPage, Total: $_totalPages',
        );
      } else {
        devtools.log(
          'Unexpected response data type: ${response.data.runtimeType}',
        );
        _transactionsError =
            'Invalid response format: Expected List or Map, got ${response.data.runtimeType}';
      }
    } else {
      devtools.log('Invalid response format or status code');
      if (response.statusCode != 200) {
        devtools.log('Non-200 status code: ${response.statusCode}');
        devtools.log('Response data: ${response.data}');
        _transactionsError =
            'Failed to load transactions (${response.statusCode})';
      } else {
        devtools.log(
          'Response data is not a Map: ${response.data.runtimeType}',
        );
        _transactionsError = 'Invalid response format';
      }
    }
    devtools.log('=== END WALLET TRANSACTIONS DEBUG ===');
  }

  Future<void> loadMoreTransactions() async {
    if (!canLoadMore || _isTransactionsLoading) return;
    _currentPage++;
    await fetchTransactions();
  }
}

class Wallet {
  final String id;
  final double availableBalance;
  final String currency;
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.availableBalance,
    required this.currency,
    required this.createdAt,
  });

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      availableBalance: _parseAmount(map['availableBalance']),
      currency: map['currency'] ?? 'USD',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String get formattedBalance =>
      MoneyHelper.formatCurrency(availableBalance, currency);

  static double _parseAmount(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

enum WalletTransactionType {
  deposit,
  withdrawal,
  payment,
  refund,
  fee,
  adjustment,
  other,

  order_income,
  tip_income,
}

enum WalletTransactionStatus { pending, completed, failed, canceled }

class WalletTransaction {
  final String id;
  final String walletId;
  final double amount;
  final WalletTransactionType type;
  final WalletTransactionStatus status;
  final String currency;
  final String? stripePayoutId;
  final DateTime? availableAt;
  final String? note;
  final String? orderId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.status,
    required this.currency,
    this.stripePayoutId,
    this.availableAt,
    this.note,
    this.orderId,
    required this.createdAt,
  });

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    devtools.log('=== PARSING WALLET TRANSACTION ===');
    devtools.log('Transaction map: $map');
    devtools.log('Map keys: ${map.keys.toList()}');

    try {
      final transaction = WalletTransaction(
        id: map['id']?.toString() ?? '',
        walletId: map['walletId']?.toString() ?? '',
        amount: Wallet._parseAmount(map['amount']),
        type: _parseTransactionType(map['type']?.toString() ?? ''),
        status: _parseTransactionStatus(map['status']?.toString() ?? ''),
        currency: map['currency']?.toString() ?? 'CAD',
        stripePayoutId: map['stripePayoutId']?.toString(),
        availableAt:
            map['availableAt'] != null
                ? DateTime.parse(map['availableAt'].toString())
                : null,
        note: map['note']?.toString(),
        orderId: map['order']?['id']?.toString() ?? map['orderId']?.toString(),
        createdAt: DateTime.parse(map['createdAt'].toString()),
      );
      devtools.log('Successfully parsed transaction: ${transaction.id}');
      return transaction;
    } catch (e) {
      devtools.log('Error parsing transaction: $e');
      devtools.log('Problematic map: $map');
      rethrow;
    }
  }

  String get formattedAmount {
    final sign =
        type == WalletTransactionType.withdrawal ||
                type == WalletTransactionType.fee ||
                type == WalletTransactionType.refund
            ? '-'
            : '+';
    return '$sign${MoneyHelper.formatCurrency(amount, currency)}';
  }

  static WalletTransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return WalletTransactionType.deposit;
      case 'withdrawal':
        return WalletTransactionType.withdrawal;
      case 'payment':
        return WalletTransactionType.payment;
      case 'refund':
        return WalletTransactionType.refund;
      case 'fee':
        return WalletTransactionType.fee;
      case 'adjustment':
        return WalletTransactionType.adjustment;
      case 'tip_income':
        return WalletTransactionType.tip_income;
      case 'order_income':
        return WalletTransactionType.order_income;
      default:
        devtools.log(
          'Unknown transaction type: $type, defaulting to order_income',
        );
        return WalletTransactionType.order_income;
    }
  }

  static WalletTransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return WalletTransactionStatus.pending;
      case 'completed':
        return WalletTransactionStatus.completed;
      case 'failed':
        return WalletTransactionStatus.failed;
      case 'canceled':
        return WalletTransactionStatus.canceled;
      default:
        return WalletTransactionStatus.pending;
    }
  }
}

class MoneyHelper {
  static String formatCurrency(double amount, String currency) {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$currency ';
    }
  }
}
