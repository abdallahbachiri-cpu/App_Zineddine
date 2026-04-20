import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/services/di/service_locator.dart';

class AccountService {
  final ApiClient _apiClient = getIt<ApiClient>();

  /// Permanently deletes the authenticated user's account and all associated
  /// data. Required by Apple App Store guidelines (GDPR / App Review 5.1.1).
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('/api/user/account');
    } catch (e) {
      rethrow;
    }
  }
}
