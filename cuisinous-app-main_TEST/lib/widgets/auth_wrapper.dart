import 'package:cuisinous/core/enums/user_type.dart';
import 'package:cuisinous/screens/account_type_selection_screen.dart';
import 'package:cuisinous/screens/auth_options_screen.dart';

import 'package:cuisinous/screens/google_register_screen.dart';
import 'package:cuisinous/screens/language_selection_screen.dart';
import 'package:cuisinous/screens/login_screen.dart';
import 'package:cuisinous/screens/main_screen.dart';
import 'package:cuisinous/screens/onboarding_screen.dart';
import 'package:cuisinous/screens/otp_verification_screen.dart';
import 'package:cuisinous/screens/splash_screen.dart';
import 'package:cuisinous/widgets/store_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/settings_provider.dart';
import 'package:cuisinous/providers/navigation_provider.dart';
import 'package:cuisinous/core/enums/navigation_item.dart';
import 'dart:developer' as devtools;

import '../services/app_service.dart';
import '../services/di/service_locator.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  bool _showOnboarding = false;
  final bool _showAuthOptions = true;

  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    devtools.log('[AuthWrapper] Initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    devtools.log('[AuthWrapper] Disposed');
    context.read<AuthProvider>().removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    // Only reset the navigation stack if the user transitioned from logged in to logged out
    if (auth.user == null && _wasLoggedIn) {
      devtools.log('[AuthWrapper] User logged out, resetting navigation stack');

      context.read<NavigationProvider>().setNavigationItem(NavigationItem.home);

      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    // Update the previous state
    _wasLoggedIn = auth.user != null;
  }

  Future<void> _initialize() async {
    final auth = context.read<AuthProvider>();
    _wasLoggedIn = auth.user != null; // set initial state
    auth.addListener(_handleAuthChange);
    final settings = context.read<SettingsProvider>();

    await auth.appService.initialize();

    await Future.wait([
      auth.initialize(),
      settings.initialize(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      // Best Practice: Request permissions exactly after UI transitions away from Splash
      // Use getIt directly to respect Service Locator architecture
      getIt<AppService>().requestAppPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    return Consumer2<AuthProvider, SettingsProvider>(
      builder: (context, auth, settings, _) {
        devtools.log(
          '[AuthWrapper] Builder called. User: ${auth.user}, Welcomed: ${settings.isWelcomed}',
        );
        if (!settings.isWelcomed) {
          if (_showOnboarding) {
            devtools.log('[AuthWrapper] Showing OnboardingScreen');
            return OnboardingScreen(
              onDone: () {
                devtools.log(
                  '[AuthWrapper] Onboarding done, marking as welcomed',
                );
                settings.markAsWelcomed();
              },
            );
          }
          devtools.log('[AuthWrapper] Showing LanguageSelectionScreen');
          return LanguageSelectionScreen(
            onLanguageSelected: () {
              devtools.log(
                '[AuthWrapper] Language selected, showing onboarding',
              );
              setState(() {
                _showOnboarding = true;
              });
            },
          );
        }

        if (auth.user == null) {
          if (_showAuthOptions) {
            devtools.log('[AuthWrapper] Showing AuthOptionsScreen');
            return AuthOptionsScreen(
              onAppleSelected: () async {
                devtools.log('[AuthWrapper] Apple selected');
                try {
                  await auth.signInWithApple();
                } catch (e) {
                  devtools.log('[AuthWrapper] Apple Sign-In failed: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(auth.error ?? 'Apple Sign-In failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              onGoogleSelected: () async {
                devtools.log('[AuthWrapper] Google selected');
                try {
                  await auth.signInWithGoogle();
                } catch (e) {
                  devtools.log('[AuthWrapper] Google Sign-In failed: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(auth.error ?? 'Google Sign-In failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          }
          return const LoginScreen();
        }

        if (auth.user!.needsGoogleOnboarding) {
          devtools.log('[AuthWrapper] Navigating to GoogleRegisterScreen');
          return GoogleRegisterScreen(
            firstName: auth.user?.firstName ?? '',
            lastName: auth.user?.lastName ?? '',
            email: auth.user?.email ?? '',
          );
        }

        if (!auth.user!.isEmailConfirmed) {
          devtools.log('[AuthWrapper] Navigating to OptVerificationScreen');
          return const OptVerificationScreen();
        }

        if (auth.currentUserType == null) {
          devtools.log(
            '[AuthWrapper] Navigating to AccountTypeSelectionScreen',
          );
          return const AccountTypeSelectionScreen();
        }

        if (auth.currentUserType == UserType.seller.name) {
          devtools.log('[AuthWrapper] Navigating to StoreWrapper');
          return const StoreWrapper();
        }

        devtools.log('[AuthWrapper] Navigating to MainScreen');
        return const MainScreen();
      },
    );
  }
}
