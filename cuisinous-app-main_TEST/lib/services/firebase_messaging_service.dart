import 'dart:developer' as devtools;
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Function(RemoteMessage)? onNotificationTapped;

  Future<void> requestNotificationPermission() async {
    devtools.log('Requesting notification permission...');
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      devtools.log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      devtools.log('User granted provisional permission');
    } else {
      devtools.log('User declined or has not accepted permission');
    }
  }

  Future<void> initialize() async {
    // Handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        devtools.log(
          'Message also contained a notification: ${message.notification}',
        );
        // Here you can use a snackbar or a notification service to show the message
      }
    });

    // Handling background message click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      devtools.log('Notification tapped (background): ${message.data}');
      onNotificationTapped?.call(message);
    });

    // Check if the app was opened from a terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      devtools.log('Notification tapped (terminated): ${initialMessage.data}');
      onNotificationTapped?.call(initialMessage);
    }
  }
}
