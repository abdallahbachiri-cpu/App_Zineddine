import 'dart:developer' as devtools;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/app_service.dart';
import '../services/di/service_locator.dart';
import '../screens/splash_screen.dart';
import 'auth_wrapper.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    devtools.log('[AppInitializer] Initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final appService = getIt<AppService>();
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthProvider>();

    try {
      // 1. Initialize Firebase Messaging structurally BEFORE everything
      await appService.initialize();

      // 2. Initialize Settings & Auth efficiently without duplicates
      await Future.wait([
        settings.initialize(),
        auth.initialize(),
        Future.delayed(const Duration(seconds: 3)), // Enforce minimum splash screen display time
      ]);

      // 3. Request permissions only ONCE tracking via SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hasRequestedPermissions = prefs.getBool('hasRequestedPermissions') ?? false;

      if (!hasRequestedPermissions) {
        // Save the flag immediately so we don't infinitely retry if it hangs
        await prefs.setBool('hasRequestedPermissions', true);
        
        // Best Practice: DO NOT await permission dialogs during splash initialization!
        // Awaiting them causes the Splash state to hang indefinitely if the OS drops the dialog.
        // Instead, we decouple it. It will safely appear exactly when the App transitions to the first screen.
        Future.delayed(const Duration(milliseconds: 800), () {
          appService.requestAppPermissions().catchError((e) {
            devtools.log('Permission request failed or hung: $e');
          });
        });
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stacktrace) {
      devtools.log('[AppInitializer] Critical initialization failure: $e', error: e, stackTrace: stacktrace);
      // In a production app, we would possibly navigate to an error state or retry component here
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }
    
    // When done, hand off to the completely decoupled routing wrapper
    return const AuthWrapper();
  }
}
