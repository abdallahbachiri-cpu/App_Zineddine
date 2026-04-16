import 'dart:convert';
import 'dart:developer' as devtools;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:uuid/uuid.dart';

class PaymentCard {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final bool isDefault;

  PaymentCard({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
    required this.isDefault,
    String? id,
  }) : id = id ?? const Uuid().v4();

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'],
      cardNumber: map['cardNumber'],
      expiryDate: map['expiryDate'],
      cvv: map['cvv'],
      cardHolderName: map['cardHolderName'],
      isDefault: map['isDefault'],
    );
  }

  PaymentCard copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? cardHolderName,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardHolderName': cardHolderName,
      'isDefault': isDefault,
    };
  }

  String get last4Digits =>
      cardNumber.length > 4
          ? cardNumber.substring(cardNumber.length - 4)
          : cardNumber;

  String get formattedExpiry => expiryDate.replaceAll('/', ' / ');
}

class PaymentCredentialsProvider extends ChangeNotifier {
  static const String _logTag = '[PaymentProvider]';
  final FlutterSecureStorage _storage;
  final List<PaymentCard> _cards = [];
  String? _userId;
  String? _selectedCardId;
  bool _isLoading = false;
  String? _error;

  PaymentCredentialsProvider({required FlutterSecureStorage storage})
    : _storage = storage {
    devtools.log('PaymentCredentialsProvider initialized', name: _logTag);
  }

  List<PaymentCard> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCardId => _selectedCardId;

  PaymentCard? get selectedCard =>
      _cards.firstWhereOrNull((c) => c.id == _selectedCardId);

  PaymentCard? get defaultCard => _cards.firstWhereOrNull((c) => c.isDefault);

  String get _storageKey => 'paymentCards_${_userId ?? 'unknown'}';

  void setCurrentUser(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _selectedCardId = null;
    loadCards();
  }

  Future<void> loadCards() async {
    _startLoading();
    devtools.log('Loading cards for user $_userId', name: _logTag);

    try {
      final data = await _storage.read(key: _storageKey);
      if (data != null) {
        _cards.clear();
        final jsonList = json.decode(data) as List;
        _cards.addAll(jsonList.map((item) => PaymentCard.fromMap(item)));

        devtools.log(
          'Loaded ${_cards.length} cards for user $_userId',
          name: _logTag,
          level: _cards.isEmpty ? 500 : 800,
          error: _cards.isEmpty ? 'No cards found' : null,
        );

        _autoSetDefaultCard();
      } else {
        devtools.log(
          'No cards found for user $_userId',
          name: _logTag,
          level: 500,
        );
      }
    } catch (e, stackTrace) {
      devtools.log(
        'Failed to load cards',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      _setError('Failed to load cards: ${e.toString()}');
    } finally {
      _stopLoading();
    }
  }

  Future<void> addCard(PaymentCard card) async {
    _startLoading();
    devtools.log(
      'Adding new card for user $_userId: ${_cardLogInfo(card)}',
      name: _logTag,
    );

    try {
      if (card.isDefault) _unsetOtherDefaults();
      _cards.add(card);
      _autoSetDefaultCard();
      await _saveCards();

      devtools.log(
        'Successfully added card ${card.id}',
        name: _logTag,
        level: 800,
      );
    } catch (e, stackTrace) {
      devtools.log(
        'Failed to add card',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      _setError('Failed to add card: ${e.toString()}');
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<void> updateCard(PaymentCard updatedCard) async {
    _startLoading();
    devtools.log(
      'Updating card ${updatedCard.id} for user $_userId',
      name: _logTag,
    );

    try {
      final index = _cards.indexWhere((c) => c.id == updatedCard.id);
      if (index == -1) throw Exception('Card not found');

      if (updatedCard.isDefault) _unsetOtherDefaults();
      _cards[index] = updatedCard;
      await _saveCards();

      devtools.log(
        'Successfully updated card ${updatedCard.id}',
        name: _logTag,
        level: 800,
      );
    } catch (e, stackTrace) {
      devtools.log(
        'Failed to update card ${updatedCard.id}',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      _setError('Failed to update card: ${e.toString()}');
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<void> deleteCard(String cardId) async {
    _startLoading();
    devtools.log('Deleting card $cardId for user $_userId', name: _logTag);

    try {
      final wasDefault = _cards.firstWhere((c) => c.id == cardId).isDefault;
      _cards.removeWhere((c) => c.id == cardId);

      if (wasDefault && _cards.isNotEmpty) {
        _cards[0] = _cards[0].copyWith(isDefault: true);
      }
      await _saveCards();

      devtools.log(
        'Successfully deleted card $cardId',
        name: _logTag,
        level: 800,
      );
    } catch (e, stackTrace) {
      devtools.log(
        'Failed to delete card $cardId',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      _setError('Failed to delete card: ${e.toString()}');
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  void selectCard(String cardId) {
    _selectedCardId = cardId;
    notifyListeners();
  }

  Future<String?> createPaymentMethod(String cardId) async {
    _startLoading();
    devtools.log('Creating payment method for card $cardId', name: _logTag);

    try {
      final card = _cards.firstWhere((c) => c.id == cardId);
      final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
        params: stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(
            billingDetails: stripe.BillingDetails(name: card.cardHolderName),
          ),
        ),
      );

      devtools.log(
        'Successfully created payment method ${paymentMethod.id} '
        'for card $cardId',
        name: _logTag,
        level: 800,
      );

      return paymentMethod.id;
    } catch (e, stackTrace) {
      devtools.log(
        'Payment method creation failed for card $cardId',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      _setError('Payment failed: ${e.toString()}');
      return null;
    } finally {
      _stopLoading();
    }
  }

  Future<void> _saveCards() async {
    final jsonString = json.encode(_cards.map((c) => c.toMap()).toList());
    await _storage.write(key: _storageKey, value: jsonString);
    notifyListeners();
  }

  void _unsetOtherDefaults() {
    for (var i = 0; i < _cards.length; i++) {
      if (_cards[i].isDefault) {
        _cards[i] = _cards[i].copyWith(isDefault: false);
      }
    }
  }

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  String _cardLogInfo(PaymentCard card) {
    return '''
    Card ID: ${card.id}
    Holder: ${card.cardHolderName}
    Last 4: ${card.last4Digits}
    Expiry: ${card.formattedExpiry}
    Default: ${card.isDefault}''';
  }

  void _autoSetDefaultCard() {
    if (_cards.isNotEmpty && !_cards.any((c) => c.isDefault)) {
      devtools.log(
        'Auto-setting default card to first in list',
        name: _logTag,
        level: 800,
      );
      _cards[0] = _cards[0].copyWith(isDefault: true);
    }
  }

  Future<void> clearUserData() async {
    devtools.log('Clearing payment data for user $_userId', name: _logTag);
    _cards.clear();
    _selectedCardId = null;
    if (_userId != null) {
      await _storage.delete(key: _storageKey);
    }
    _userId = null;
    notifyListeners();
    devtools.log('Payment data cleared successfully', name: _logTag);
  }
}

extension FirstWhereExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
