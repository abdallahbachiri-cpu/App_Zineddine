import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/settings_provider.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/screens/splash_screen.dart';
import 'package:cuisinous/screens/onboarding_screen.dart';
import 'package:cuisinous/screens/language_selection_screen.dart';
import 'package:cuisinous/screens/auth_options_screen.dart';

import '../helpers/mock_settings_provider.dart';
import '../helpers/mock_auth_provider.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadAppFonts();
    await S.load(const Locale('en'));
  });

  Widget wrapper(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => MockSettingsProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('fr')],
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: child,
      ),
    );
  }

  final devices = {
    'phone': Device.phone,
    'iphone11': Device.iphone11,
    'tabletPortrait': Device.tabletPortrait,
  };

  for (final deviceEntry in devices.entries) {
    final devName = deviceEntry.key;
    final device = deviceEntry.value;

    testGoldens('Splash Screen Golden - $devName', (tester) async {
      await tester.binding.setSurfaceSize(device.size);
      tester.binding.window.physicalSizeTestValue = device.size;
      tester.binding.window.devicePixelRatioTestValue = device.devicePixelRatio;

      await tester.pumpWidget(wrapper(const SplashScreen()));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'splash_screen_$devName');

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testGoldens('Language Selection Screen Golden - $devName', (tester) async {
      await tester.binding.setSurfaceSize(device.size);
      tester.binding.window.physicalSizeTestValue = device.size;
      tester.binding.window.devicePixelRatioTestValue = device.devicePixelRatio;

      await tester.pumpWidget(wrapper(const LanguageSelectionScreen()));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'language_selection_screen_$devName');

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testGoldens('Auth Options Screen Golden - $devName', (tester) async {
      await tester.binding.setSurfaceSize(device.size);
      tester.binding.window.physicalSizeTestValue = device.size;
      tester.binding.window.devicePixelRatioTestValue = device.devicePixelRatio;

      await tester.pumpWidget(wrapper(const AuthOptionsScreen()));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'auth_options_screen_$devName');

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testGoldens('Onboarding Screen Golden - $devName', (tester) async {
      await tester.binding.setSurfaceSize(device.size);
      tester.binding.window.physicalSizeTestValue = device.size;
      tester.binding.window.devicePixelRatioTestValue = device.devicePixelRatio;

      await tester.pumpWidget(wrapper(const OnboardingScreen()));

      // Slide 1
      await tester.pump(const Duration(milliseconds: 500));
      await screenMatchesGolden(tester, 'onboarding_screen_slide_1_$devName');

      // Slide 2
      await tester.tap(find.text('Next').last);
      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'onboarding_screen_slide_2_$devName');

      // Slide 3
      await tester.tap(find.text('Next').last);
      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'onboarding_screen_slide_3_$devName');

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  }
}
