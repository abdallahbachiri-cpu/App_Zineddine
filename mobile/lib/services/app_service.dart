import 'dart:developer' as devtools;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cuisinous/providers/auth_provider.dart';
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
    final orderId = message.data['orderId'];

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
      // FlutterRingtonePlayer.playNotification();
      if (notification.notification != null) {
        showSnackBar(
          notification.notification!.title ?? 'Notification',
          notification.notification!.body ?? '',
        );
      }
    });
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
