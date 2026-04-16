import 'dart:developer' as devtools;
import 'package:flutter/foundation.dart';
import 'package:cuisinous/data/db/app_settings.dart';
import 'package:cuisinous/data/models/settings_model.dart';
import '../core/mixins/error_handling_mixin.dart';
import '../services/app_service.dart';
import '../services/di/service_locator.dart';

class SettingsProvider with ChangeNotifier, ErrorHandlingMixin {
  final AppSettings _appSettings;
  Settings? _settings;
  bool _isLoading = false;

  SettingsProvider({required AppSettings appSettings})
    : _appSettings = appSettings {
    devtools.log('SettingsProvider initialized');
  }

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isDarkTheme => _settings?.theme == 1;
  String get currentLanguage => _settings?.languageCode ?? 'fr';
  String get currentCurrency => _settings?.currency ?? 'USD';
  bool get isWelcomed => _settings?.isWelcomed ?? false;
  bool get isGoogleAuthUser => _settings?.isGoogleAuthUser ?? false;
  bool get hasCompletedRegister => _settings?.hasCompletedRegister ?? false;

  Future<void> initialize() async {
    devtools.log('Initializing settings provider...');
    await loadSettings();
  }

  Future<void> loadSettings() async {
    devtools.log('Loading settings from database...');
    _setLoading(true);
    try {
      _settings = await _appSettings.getSettings();
      if (_settings == null) {
        devtools.log('No settings found, creating defaults...');
        final defaultSettings = Settings(
          id: "default_settings",
          languageCode: 'fr',
          currency: 'CAD',
          isWelcomed: false,
          theme: 0,
          isGoogleAuthUser: false,
          hasCompletedRegister: true,
        );

        await _persistSettings(defaultSettings);
        _settings = defaultSettings;
      }
      clearError();
      devtools.log('Settings loaded successfully: ${_settings?.toMap()}');
    } catch (e, stackTrace) {
      _settings = null;
      handleError(e, stackTrace, fallbackMessage: 'Failed to load settings');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _persistSettings(Settings newSettings) async {
    final action = _settings != null ? 'Updating' : 'Creating';
    devtools.log('$action settings: ${newSettings.toMap()}');

    try {
      final exists = _settings != null;
      final success =
          exists
              ? await _appSettings.updateSettings(newSettings)
              : await _appSettings.insertSettings(newSettings);

      if (success) {
        devtools.log('Settings persisted successfully');
        _settings = newSettings;
        clearError();
        notifyListeners();
      } else {
        devtools.log('Failed to persist settings', level: 1000);
        error = 'Failed to save settings';
        notifyListeners();
      }
      return success;
    } catch (e, stackTrace) {
      handleError(
        e,
        stackTrace,
        fallbackMessage: 'Settings persistence failed',
      );
      return false;
    }
  }

  Future<void> updateTheme(int theme) async {
    if (_settings == null) return;
    devtools.log('Updating theme to: ${theme == 1 ? 'Dark' : 'Light'}');
    final newSettings = _settings!.copyWith(theme: theme);
    await _persistSettings(newSettings);
  }

  Future<void> toggleTheme() async {
    final newTheme = isDarkTheme ? 0 : 1;
    devtools.log(
      'Toggling theme from ${isDarkTheme ? 'Dark' : 'Light'} '
      'to ${newTheme == 1 ? 'Dark' : 'Light'}',
    );
    await updateTheme(newTheme);
  }

  Future<void> updateLanguage(String languageCode) async {
    if (_settings == null) return;
    devtools.log('Updating language to: $languageCode');
    final newSettings = _settings!.copyWith(languageCode: languageCode);
    await _persistSettings(newSettings);
  }

  Future<void> updateCurrency(String currency) async {
    if (_settings == null) return;
    devtools.log('Updating currency to: $currency');
    final newSettings = _settings!.copyWith(currency: currency);
    await _persistSettings(newSettings);
  }

  Future<void> markAsWelcomed() async {
    if (_settings == null) return;
    devtools.log('Marking user as welcomed');
    final newSettings = _settings!.copyWith(isWelcomed: true);
    await _persistSettings(newSettings);
  }

  Future<void> markAsGoogleAuthUser() async {
    if (_settings == null) return;
    devtools.log('Marking user as Google auth user');
    final newSettings = _settings!.copyWith(isGoogleAuthUser: true);
    await _persistSettings(newSettings);
  }

  Future<void> markAsCompletedRegister(bool isRegisterCompleted) async {
    if (_settings == null) return;
    devtools.log('Marking user as completed register');
    final newSettings = _settings!.copyWith(
      hasCompletedRegister: isRegisterCompleted,
    );
    await _persistSettings(newSettings);
  }

  Future<void> resetSettings() async {
    if (_settings == null) return;
    devtools.log('Resetting settings for ID: ${_settings!.id}');
    try {
      final success = await _appSettings.deleteSettings(_settings!.id);
      if (success) {
        devtools.log('Settings reset successfully');
        _settings = null;
        notifyListeners();
      } else {
        devtools.log('Failed to reset settings', level: 1000);
        error = 'Failed to reset settings';
        notifyListeners();
      }
    } catch (e, stackTrace) {
      handleError(e, stackTrace, fallbackMessage: 'Settings reset failed');
    }
  }

  void _setLoading(bool loading) {
    devtools.log('Loading state changed: ${loading ? 'STARTED' : 'ENDED'}');
    _isLoading = loading;
    notifyListeners();
  }
}
