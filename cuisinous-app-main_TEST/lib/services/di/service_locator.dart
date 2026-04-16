import 'package:cuisinous/core/constants/app_consts.dart';
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
import 'package:cuisinous/providers/seller_order_provider.dart';
import 'package:cuisinous/providers/seller_rating_provider.dart';
import 'package:cuisinous/providers/seller_allergen_provider.dart';
import 'package:cuisinous/providers/settings_provider.dart';
import 'package:cuisinous/providers/stripe_provider.dart';
import 'package:cuisinous/providers/statistics_provider.dart';
import 'package:cuisinous/providers/wallet_provider.dart';
import 'package:cuisinous/providers/notification_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../data/db/app_settings.dart';
import '../../data/db/db_helper.dart';
import '../../providers/user_provider.dart';
import '../network/api_client_service.dart';
import '../firebase_messaging_service.dart';
import '../app_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await getIt.reset();

  _registerLocalDataDependencies();
  _registerCoreDependencies();
}

void _registerCoreDependencies() {
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(storage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: AppConsts.apiBaseUrl),
  );
  getIt.registerLazySingleton<SettingsProvider>(
    () => SettingsProvider(appSettings: getIt<AppSettings>()),
  );
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      googleSignIn: getIt<GoogleSignIn>(),
      storage: getIt<SecureStorageService>(),
      apiClient: getIt<ApiClient>(),
    ),
  );

  getIt.registerLazySingleton<UserProvider>(
    () => UserProvider(
      apiClient: getIt<ApiClient>(),
      authProvider: getIt<AuthProvider>(),
    ),
  );
  getIt.registerLazySingleton<FoodStoreProvider>(
    () => FoodStoreProvider(
      apiClient: getIt<ApiClient>(),
      authProvider: getIt<AuthProvider>(),
    ),
  );
  getIt.registerLazySingleton<IngredientsProvider>(
    () => IngredientsProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DishProvider>(
    () => DishProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SellerDishProvider>(
    () => SellerDishProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DishIngredientsProvider>(
    () => DishIngredientsProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BuyerLocationsProvider>(
    () => BuyerLocationsProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CartProvider>(
    () => CartProvider(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<BuyerOrderProvider>(
    () => BuyerOrderProvider(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SellerOrderProvider>(
    () => SellerOrderProvider(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CategoryProvider>(
    () => CategoryProvider(
      apiClient: getIt<ApiClient>(),
      authProvider: getIt<AuthProvider>(),
    ),
  );
  getIt.registerLazySingleton<BuyerRatingProvider>(
    () => BuyerRatingProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SellerRatingProvider>(
    () => SellerRatingProvider(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<PaymentCredentialsProvider>(
    () => PaymentCredentialsProvider(storage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<WalletProvider>(
    () => WalletProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<StripeProvider>(
    () => StripeProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SellerAllergenProvider>(
    () => SellerAllergenProvider(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<StatisticsProvider>(
    () => StatisticsProvider(apiClient: getIt<ApiClient>()),
  );

  // New Services
  getIt.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );
  getIt.registerLazySingleton<AppService>(
    () => AppService(
      firebaseMessagingService: getIt<FirebaseMessagingService>(),
    ),
  );
  getIt.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(
      apiClient: getIt<ApiClient>(),
      authProvider: getIt<AuthProvider>(),
      appService: getIt<AppService>(),
      settingsProvider: getIt<SettingsProvider>(),
    ),
  );
}

void _registerLocalDataDependencies() {
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  getIt.registerFactory<AppSettings>(
    () => AppSettings(databaseHelper: getIt<DatabaseHelper>()),
  );
}

final List<ChangeNotifierProvider> appProviders = [
  ChangeNotifierProvider(create: (context) => getIt<SettingsProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<AuthProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<UserProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<FoodStoreProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<IngredientsProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<DishProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<SellerDishProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<DishIngredientsProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<BuyerLocationsProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<CartProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<BuyerOrderProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<SellerOrderProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<CategoryProvider>()),
  ChangeNotifierProvider(
    create: (context) => getIt<PaymentCredentialsProvider>(),
  ),
  ChangeNotifierProvider(create: (context) => getIt<SellerRatingProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<BuyerRatingProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<WalletProvider>()),
  ChangeNotifierProvider(create: (context) => getIt<NotificationProvider>()),
];
