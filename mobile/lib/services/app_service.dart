import 'dart:developer' as devtools;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/buyer_order_provider.dart';
import 'package:cuisinous/providers/vendor_order_provider.dart';
import 'package:cuisinous/screens/buyer_order_details_screen.dart';
import 'package:cuisinous/screens/vendor_orders_screen.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'firebase_messaging_service.dart';

class AppService {
  final FirebaseMessagingService _firebaseMessagingService;
  SharedPreferences? sharedPreferences;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  AppService({
    required FirebaseMessagingService firebaseMessagingService,
  }) : _firebaseMessagingService = firebaseMessagingService;

  Future<void> initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    devtools.log('Initializing AppService...');

    _firebaseMessagingService.onNotificationTapped = handleNotificationClick;

    // Initialize notification listeners
    await _firebaseMessagingService.initialize();
    firebaseCloudMessaging();
  }

  void handleNotificationClick(RemoteMessage message) {
    devtools.log('[AppService] Handling notification click: ${message.data}');
    if (message.data['update_available'] == 'true') {
      _showUpdateDialogByData(message);
      return;
    }

    if (message.data['broadcast_message'] == 'true') {
      _showBroadcastDialogByData(message);
      return;
    }

    _refreshOrderLists();

    final orderId = message.data['key'] ?? message.data['orderId'];
    if (orderId != null) {
      final authProvider = getIt<AuthProvider>();
      final isSeller = authProvider.currentUserType == 'seller';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder:
              (_) => isSeller
                  ? VendorOrderDetailScreen(orderId: orderId)
                  : BuyerOrderDetailScreen(orderId: orderId),
        ),
      );
    }
  }

  void firebaseCloudMessaging() {
    FirebaseMessaging.onMessage.listen((notification) {
      if (notification.data['update_available'] == 'true') {
        _showUpdateDialogByData(notification);
        return;
      }

      if (notification.data['broadcast_message'] == 'true') {
        _showBroadcastDialogByData(notification);
        return;
      }

      if (notification.data['key'] != null || notification.data['orderId'] != null) {
        _refreshOrderLists(silent: true);
      }

      if (notification.notification != null) {
        showSnackBar(
          notification.notification!.title ?? 'Notification',
          notification.notification!.body ?? '',
        );
      }
    });
  }

  void _refreshOrderLists({bool silent = true}) {
    final userType = getIt<AuthProvider>().currentUserType;
    if (userType == null) return; // not logged in yet

    if (userType == 'seller') {
      getIt<VendorOrderProvider>().refreshOrders(silent: silent);
    } else {
      getIt<BuyerOrderProvider>().refreshOrders(silent: silent);
    }
  }

  void showSnackBar(String title, String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showUpdateDialogByData(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final latestVersion = message.data['latest_version'] ?? '';
    final updateUrl = message.data['update_url'] ?? '';
    final currentVersion = message.data['current_version'] ?? '';
    final forceUpdate = message.data['force_update'] == 'true';
    final notificationTitle = message.notification?.title ?? 'Update Available';
    final notificationBody = message.notification?.body ?? 'A new version of the app is available.';

    _showUpdateDialog(
      context,
      isForced: forceUpdate,
      updateUrl: updateUrl,
      latestVersion: latestVersion,
      currentVersion: currentVersion,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
  }

  Future<void> _showUpdateDialog(
    BuildContext context, {
    required bool isForced,
    required String updateUrl,
    required String latestVersion,
    required String currentVersion,
    required String notificationTitle,
    required String notificationBody,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !isForced,
      builder: (context) {
        return AlertDialog(
          title: Text(isForced ? 'Update Required' : notificationTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notificationBody),
              const SizedBox(height: 12),
              if (currentVersion.isNotEmpty)
                Text('Installed: $currentVersion', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (latestVersion.isNotEmpty)
                Text('Latest: $latestVersion', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: <Widget>[
            if (!isForced)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
            TextButton(
              onPressed: () {
                final url = updateUrl.isNotEmpty ? updateUrl : _defaultStoreUrl();
                _launchUrl(url);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showBroadcastDialogByData(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final notificationTitle = message.notification?.title ?? message.data['title'] ?? 'Announcement';
    final notificationBody = message.notification?.body ?? message.data['body'] ?? 'A new announcement has arrived.';
    final actionUrl = message.data['action_url'] ?? '';

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(notificationTitle),
          content: Text(notificationBody),
          actions: <Widget>[
            if (actionUrl.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchUrl(actionUrl);
                },
                child: const Text('Open'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _defaultStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=ca.cuisinous';
    }
    if (Platform.isIOS) {
      return 'https://apps.apple.com/app/idYOUR_APP_ID';
    }
    return '';
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> requestAppPermissions() async {
    devtools.log('Requesting App Permissions...');
    await _firebaseMessagingService.requestNotificationPermission();
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<String?> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token;
  }

  Future<void> setUserId(String userId) async {
    await sharedPreferences?.setString('user_id', userId);
  }

  Future<String?> getUserId() async {
    return sharedPreferences?.getString('user_id');
  }

  Future<void> clearUserId() async {
    await sharedPreferences?.remove('user_id');
  }
}
