import 'package:flutter/foundation.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthProvider extends Mock implements AuthProvider {
  final _notifier = ChangeNotifier();

  @override
  void addListener(VoidCallback listener) => _notifier.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _notifier.removeListener(listener);

  @override
  void dispose() => _notifier.dispose();

  @override
  void notifyListeners() => _notifier.notifyListeners();

  @override
  bool get isLoading => false;
}
