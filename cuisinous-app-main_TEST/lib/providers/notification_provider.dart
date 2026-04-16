import 'dart:developer' as devtools;

import 'package:flutter/foundation.dart';
import 'package:cuisinous/data/models/notification.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:cuisinous/core/constants/api_endpoints.dart';
import 'package:cuisinous/core/errors/exceptions.dart';
import 'package:cuisinous/core/mixins/error_handling_mixin.dart';
import 'package:cuisinous/services/app_service.dart';
import 'package:cuisinous/providers/settings_provider.dart';

class NotificationProvider with ChangeNotifier, ErrorHandlingMixin {
  final ApiClient _apiClient;
  final AuthProvider _authProvider;
  final AppService _appService;
  final SettingsProvider _settingsProvider;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => n.isShow == false).length;
  String get currentLanguage => _settingsProvider.currentLanguage;

  NotificationProvider({
    required ApiClient apiClient,
    required AuthProvider authProvider,
    required AppService appService,
    required SettingsProvider settingsProvider,
  })  : _apiClient = apiClient,
        _authProvider = authProvider,
        _appService = appService,
        _settingsProvider = settingsProvider;

  void _verifyAuth() {
    if (_authProvider.user == null) {
      throw ApiException(401, 'User must be logged in to access notifications');
    }
  }

  Future<void> fetchNotifications() async {
    devtools.log('[Notification] Starting fetchNotifications');
    try {
      _verifyAuth();
      _isLoading = true;
      clearError();
      notifyListeners();
      
      final storedId = await _appService.getUserId();
      devtools.log('[Notification] User ID from SharedPreferences: $storedId');

      if (storedId == null) {
        throw ApiException(401, 'User ID not found in storage');
      }

      final response = await _apiClient.get(
        ApiEndpoints.notificationsReceiver(storedId),
      );

      final newNotifications = (response.data as List)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _notifications = newNotifications;
      devtools.log('[Notification] Fetched ${_notifications.length} notifications successfully');
    } on ApiException catch (e, s) {
      if (e.statusCode == 404) {
        _notifications = [];
        clearError();
      } else {
        handleError(e, s);
      }
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to fetch notifications');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    devtools.log('[Notification] Marking notification $notificationId as read');
    try {
      _verifyAuth();
      
      // Optimistic update for snappy UI
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isShow = true;
        notifyListeners();
      }

      await _apiClient.put(
        ApiEndpoints.notificationMarkShown(notificationId),
      );
      
      devtools.log('[Notification] Marked as read successfully');
    } catch (e, s) {
      handleError(e, s, fallbackMessage: 'Failed to mark notification as read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    devtools.log('[Notification] Deleting notification $notificationId');
    try {
      _verifyAuth();
      
      // Optimistic delete for snappy UI
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      await _apiClient.delete(
        ApiEndpoints.notificationDelete(notificationId),
      );
      
      devtools.log('[Notification] Deleted successfully');
    } catch (e, s) {
      // If it fails on the server, we re-fetch to restore our local state perfectly
      fetchNotifications();
      handleError(e, s, fallbackMessage: 'Failed to delete notification');
    }
  }

  String getNotificationTitle(NotificationModel notification) {
    return notification.getLocalizedTitle(currentLanguage);
  }

  String getNotificationBody(NotificationModel notification) {
    return notification.getLocalizedBody(currentLanguage);
  }
}
