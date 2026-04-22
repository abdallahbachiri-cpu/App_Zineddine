import 'package:cuisinous/core/config/environment_config.dart';
import 'package:cuisinous/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/buyer_location_provider.dart';
import 'package:cuisinous/providers/buyer_order_provider.dart';
import 'package:cuisinous/providers/buyer_rating_provider.dart';
import 'package:cuisinous/providers/cart_provider.dart';
import 'package:cuisinous/providers/category_provider.dart';
import 'package:cuisinous/providers/dish_ingredients_provider.dart';
import 'package:cuisinous/providers/dish_provider.dart';
import 'package:cuisinous/providers/food_store_provider.dart';
import 'package:cuisinous/providers/ingredients_provider.dart';
import 'package:cuisinous/providers/payment_creds_provider.dart';
import 'package:cuisinous/providers/vendor_order_provider.dart';
import 'package:cuisinous/providers/vendor_rating_provider.dart';
import 'package:cuisinous/providers/vendor_allergen_provider.dart';
import 'package:cuisinous/providers/settings_provider.dart';
import 'package:cuisinous/providers/stripe_provider.dart';
import 'package:cuisinous/providers/user_provider.dart';
import 'package:cuisinous/providers/wallet_provider.dart';
import 'package:cuisinous/providers/statistics_provider.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:cuisinous/services/app_service.dart';
import 'package:cuisinous/widgets/app_initializer.dart';
import 'package:cuisinous/providers/navigation_provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';

/// Must be a top-level function — called by Firebase when a message arrives
/// while the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // No provider access here; FCM stores the notification and delivers it
  // via getInitialMessage / onMessageOpenedApp when the app resumes.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await EnvironmentConfig.load();

  Stripe.publishableKey = EnvironmentConfig.stripePublishableKey;
  Stripe.merchantIdentifier = EnvironmentConfig.stripeMerchantIdentifier;
  await Stripe.instance.applySettings();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await configureDependencies();

  final appService = getIt<AppService>();
  await appService.initialize();

  final settingsProvider = getIt<SettingsProvider>();
  await settingsProvider.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) => runApp(
      DevicePreview(
        enabled: false,
        builder: (context) => const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => getIt<SettingsProvider>()),
        ChangeNotifierProvider(create: (context) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (context) => getIt<UserProvider>()),
        ChangeNotifierProvider(create: (context) => getIt<FoodStoreProvider>()),
        ChangeNotifierProvider(
          create: (context) => getIt<IngredientsProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => getIt<DishProvider>()),
        ChangeNotifierProvider(
          create: (context) => getIt<SellerDishProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<DishIngredientsProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<VendorAllergenProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<BuyerLocationsProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => getIt<CartProvider>()),
        ChangeNotifierProvider(
          create: (context) => getIt<BuyerOrderProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<VendorOrderProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => getIt<CategoryProvider>()),
        ChangeNotifierProvider(
          create: (context) => getIt<PaymentCredentialsProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<VendorRatingProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<BuyerRatingProvider>(),
        ),
        ChangeNotifierProvider(create: (context) => getIt<WalletProvider>()),
        ChangeNotifierProvider(
          create: (context) => getIt<StatisticsProvider>(),
        ),

        ChangeNotifierProvider(create: (context) => getIt<StripeProvider>()),
        ChangeNotifierProvider(create: (context) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: FutureBuilder(
        future: getIt.allReady(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }
          return Consumer<SettingsProvider>(
            builder: (context, settingsProvider, _) {
              return MaterialApp(
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
                locale:
                    DevicePreview.locale(context) ??
                    _getLocale(settingsProvider),
                builder: DevicePreview.appBuilder,
                localeResolutionCallback: _localeResolution,
                themeMode: ThemeMode.light,
                scaffoldMessengerKey: AppService.scaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                navigatorKey: AppService.navigatorKey,
                home: const AppInitializer(),
                onGenerateRoute: onGenerateRoute,
              );
            },
          );
        },
      ),
    );
  }

  Locale _getLocale(SettingsProvider provider) {
    return Locale(provider.currentLanguage);
  }

  Locale _localeResolution(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    final settingsProvider = getIt<SettingsProvider>();
    final savedLocale = Locale(settingsProvider.currentLanguage);
    return supportedLocales.contains(savedLocale)
        ? savedLocale
        : const Locale('fr', 'FR');
  }
}
