import 'dart:developer' as devtools;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

mixin ErrorHandlingMixin on ChangeNotifier {
  String? _error;
  String? get error => _error;

  @protected
  set error(String? value) => _error = value;

  void handleError(
    Object e,
    StackTrace? stackTrace, {
    String? fallbackMessage,
  }) {
    devtools.log(
      '[${runtimeType}][Error] ${e.toString()}',
      error: e,
      stackTrace: stackTrace,
    );
    if (e is ApiFailure) {
      _error = _parseErrorMessage(e.message);
    } else if (e is ApiException) {
      _error = _parseErrorMessage(e.message);
    } else if (e is FormatException) {
      _error = 'Unexpected response from server.';
    } else if (e is DioException) {
      _error = _parseErrorMessage(e.message ?? 'Network error occurred');
    } else {
      _error = fallbackMessage ?? 'An unexpected error occurred.';
    }
    notifyListeners();
  }

  String _parseErrorMessage(String message) {
    try {
      if (message.trim().startsWith('{') && message.trim().endsWith('}')) {
        return message;
      }
      return message;
    } catch (_) {
      return message;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
