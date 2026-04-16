import 'package:flutter/material.dart';
import 'package:cuisinous/providers/settings_provider.dart';
import 'package:cuisinous/data/models/settings_model.dart';

class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  @override
  String get currentLanguage => 'en';

  @override
  bool get isLoading => false;

  @override
  bool get isDarkTheme => false;

  @override
  bool get isWelcomed => false;

  @override
  bool get isGoogleAuthUser => false;

  @override
  bool get hasCompletedRegister => true;

  @override
  String get currentCurrency => 'USD';

  @override
  Settings? get settings => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> loadSettings() async {}

  @override
  Future<void> updateTheme(int theme) async {}

  @override
  Future<void> toggleTheme() async {}

  @override
  Future<void> updateLanguage(String languageCode) async {}

  @override
  Future<void> updateCurrency(String currency) async {}

  @override
  Future<void> markAsWelcomed() async {}

  @override
  Future<void> markAsGoogleAuthUser() async {}

  @override
  Future<void> markAsCompletedRegister(bool isRegisterCompleted) async {}

  @override
  Future<void> resetSettings() async {}

  @override
  void clearError() {}

  @override
  String? get error => null;

  @override
  set error(String? error) {}

  @override
  void handleError(
    Object e,
    StackTrace? stackTrace, {
    String? fallbackMessage,
  }) {
    // TODO: implement handleError
  }
}
