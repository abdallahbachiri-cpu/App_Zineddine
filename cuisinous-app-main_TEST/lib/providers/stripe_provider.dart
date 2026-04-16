import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as devtools;
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/errors/failures.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';

class StripeProvider with ChangeNotifier {
  final ApiClient _apiClient;

  StripeProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  StripeAccount? _stripeAccount;
  bool _isLoading = false;
  String? _error;
  String? _onboardingUrl;
  bool _isPayoutLoading = false;
  String? _payoutError;
  PayoutResult? _lastPayoutResult;

  StripeAccount? get stripeAccount => _stripeAccount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get onboardingUrl => _onboardingUrl;
  bool get isPayoutLoading => _isPayoutLoading;
  String? get payoutError => _payoutError;
  PayoutResult? get lastPayoutResult => _lastPayoutResult;

  bool get hasStripeAccount => _stripeAccount?.hasStripeAccount ?? false;

  Future<void> setupStripeAccount() async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      _error = null;

      Future.microtask(notifyListeners);

      final response = await _apiClient.post(ApiEndpoints.sellerStripeSetup);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        _onboardingUrl = data['onboarding_url'];
        _stripeAccount = StripeAccount(
          hasStripeAccount: data['stripe_account_id'] != null,
          stripeAccountId: data['stripe_account_id'],
          onboardingComplete: data['onboarding_complete'] ?? false,
        );
      } else {
        throw ApiFailure('Failed to setup Stripe account', response.statusCode);
      }
    } on DioException catch (e) {
      _error = _parseDioError(e, 'Failed to setup Stripe account');
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStripeStatus() async {
    try {
      _isLoading = true;
      _error = null;

      Future.microtask(notifyListeners);

      final response = await _apiClient.get(ApiEndpoints.sellerStripeStatus);
      if (response.statusCode == 200) {
        _stripeAccount = StripeAccount.fromMap(response.data);
      } else {
        throw ApiFailure('Failed to fetch Stripe status', response.statusCode);
      }
    } on DioException catch (e) {
      _error = _parseDioError(e, 'Failed to load Stripe status');
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPayout({double? amount}) async {
    if (_isPayoutLoading) return;
    try {
      _isPayoutLoading = true;
      _payoutError = null;
      _lastPayoutResult = null;

      Future.microtask(notifyListeners);

      final Map<String, dynamic> data = {};
      if (amount != null) {
        data['amount'] = amount;
      }
      final response = await _apiClient.post(
        ApiEndpoints.sellerStripePayout,
        body: data,
      );
      if (response.statusCode == 200) {
        _lastPayoutResult = PayoutResult.fromMap(response.data);
      } else {
        throw ApiFailure('Failed to request payout', response.statusCode);
      }
    } on DioException catch (e) {
      _payoutError = _parseDioError(e, 'Failed to request payout');
    } catch (e) {
      _payoutError = 'An unexpected error occurred';
    } finally {
      _isPayoutLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _stripeAccount = null;
    _error = null;
    _onboardingUrl = null;
    _payoutError = null;
    _lastPayoutResult = null;
    _isLoading = false;
    _isPayoutLoading = false;

    Future.microtask(notifyListeners);
  }

  String _parseDioError(DioException e, String defaultMessage) {
    return defaultMessage;
  }
}

class StripeAccount {
  final bool hasStripeAccount;
  final String? stripeAccountId;
  final bool onboardingComplete;

  StripeAccount({
    required this.hasStripeAccount,
    this.stripeAccountId,
    required this.onboardingComplete,
  });

  factory StripeAccount.fromMap(Map<String, dynamic> map) {
    return StripeAccount(
      hasStripeAccount: map['has_stripe_account'] ?? false,
      stripeAccountId: map['stripe_account_id'],
      onboardingComplete: map['onboarding_complete'] ?? false,
    );
  }
}

class PayoutResult {
  final String? message;
  final String? payoutId;
  final double? amount;
  final String? currency;
  final DateTime? estimatedArrival;

  PayoutResult({
    this.message,
    this.payoutId,
    this.amount,
    this.currency,
    this.estimatedArrival,
  });

  factory PayoutResult.fromMap(Map<String, dynamic> map) {
    return PayoutResult(
      message: map['message'],
      payoutId: map['payout_id'],
      amount: _parseAmount(map['amount']),
      currency: map['currency'],
      estimatedArrival:
          map['estimated_arrival'] != null
              ? DateTime.parse(map['estimated_arrival'])
              : null,
    );
  }

  static double? _parseAmount(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? get formattedAmount {
    if (amount == null || currency == null) return null;
    return '${_getCurrencySymbol(currency!)}${amount!.toStringAsFixed(2)}';
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
