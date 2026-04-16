import 'package:cuisinous/core/enums/navigation_item.dart';
import 'package:cuisinous/data/models/food_store.dart';
import 'package:cuisinous/screens/account_type_selection_screen.dart';
import 'package:cuisinous/screens/address_management_screen.dart';
import 'package:cuisinous/screens/menu_item_form_screen.dart';
import 'package:cuisinous/screens/menu_management_screen.dart';
import 'package:cuisinous/screens/edit_address_screen.dart';
import 'package:cuisinous/screens/ingredients_screen.dart';
import 'package:cuisinous/screens/language_selection_screen.dart';
import 'package:cuisinous/screens/login_screen.dart';
import 'package:cuisinous/screens/main_screen.dart';
import 'package:cuisinous/screens/manage_menu_ingredients_screen.dart';
import 'package:cuisinous/screens/onboarding_screen.dart';
import 'package:cuisinous/screens/otp_verification_screen.dart';
import 'package:cuisinous/screens/register_screen.dart';
import 'package:cuisinous/screens/vendor_wallet_screen.dart';
import 'package:cuisinous/screens/vendor_analytics_screen.dart';
import 'package:cuisinous/widgets/store_wrapper.dart';
import 'package:cuisinous/screens/settings_screen.dart';
import 'package:cuisinous/screens/splash_screen.dart';
import 'package:cuisinous/screens/vendor_store_form_screen.dart';
import 'package:cuisinous/screens/store_home_screen.dart';
import 'package:cuisinous/screens/store_verification_request_screen.dart';
import 'package:cuisinous/screens/google_register_screen.dart';
import 'package:cuisinous/screens/user_info_screen.dart';
import 'package:cuisinous/screens/password_recovery_screen.dart';
import 'package:cuisinous/screens/vendor_notifications_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String languageSelection = '/language-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String userType = '/user-type';

  static const String home = '/home';
  static const String orders = '/orders';
  static const String cart = '/cart';
  static const String explore = '/explore';

  static const String store = '/store';
  static const String createStore = '/create-store';
  static const String editStore = '/edit-store';
  static const String storeRequest = '/store-request';
  static const String storeHome = '/store-home';

  static const String ingredients = '/ingredients';

  static const String dishManagement = '/dishes';
  static const String editDish = '/edit-dish';
  static const String createDish = '/create-dish';

  static const String manageDishIngredients = '/manage-dish-ingredients';
  static const String addDishIngredient = '/add-dish-ingredient';
  static const String editDishIngredient = '/edit-dish-ingredient';

  static const String addressManagement = '/address-management';
  static const String createAddress = '/create-address';
  static const String editAddress = '/edit-address';

  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static const String orderManagement = '/order-management';
  static const String orderDetails = '/order-details';
  static const String language = '/language';

  static const String sellerWallet = '/seller-wallet';
  static const String sellerStats = '/seller-stats';
  static const String sellerWalletMock = '/seller-wallet-mock';

  static const String optVerification = '/otp-verification';

  static const String googleRegister = '/google-register';
  static const String passwordRecovery = '/password-recovery';
  static const String notificationSeller = '/notification-seller';

  static Route<dynamic> mainScreenRoute(NavigationItem? initialTab) {
    return MaterialPageRoute(
      builder: (_) => MainScreen(initialNavigationItem: initialTab),
    );
  }
}

const String initialRoute = AppRouter.splash;

final Map<String, WidgetBuilder> appRoutes = {
  AppRouter.splash: (context) => const SplashScreen(),
  AppRouter.languageSelection: (context) => const LanguageSelectionScreen(),
  AppRouter.login: (context) => const LoginScreen(),
  AppRouter.register: (context) => const RegisterScreen(),
  AppRouter.userType: (context) => const AccountTypeSelectionScreen(),
  AppRouter.onboarding: (context) => const OnboardingScreen(),
  AppRouter.home: (context) => const MainScreen(),
  AppRouter.store: (context) => const StoreHomeScreen(),
  AppRouter.createStore: (context) => const VendorStoreFormScreen(),
  AppRouter.ingredients: (context) => const IngredientsScreen(),
  AppRouter.dishManagement: (context) => const MenuManagementScreen(),
  AppRouter.createDish: (context) => const MenuItemFormScreen(),
  AppRouter.storeRequest: (context) => const StoreVerificationRequestScreen(),
  AppRouter.storeHome: (context) => const StoreWrapper(),
  AppRouter.addressManagement: (context) => const AddressManagementScreen(),
  AppRouter.createAddress: (context) => const AddressFormScreen(),
  AppRouter.profile: (context) => const UserProfileScreen(),
  AppRouter.language: (context) => const LanguageScreen(),
  AppRouter.sellerWallet: (context) => const VendorWalletScreen(),
  AppRouter.sellerStats: (context) => const VendorAnalyticsScreen(),
  AppRouter.optVerification: (context) => const OptVerificationScreen(),
  AppRouter.passwordRecovery: (context) => const PasswordRecoveryScreen(),
  AppRouter.notificationSeller: (context) => const VendorNotificationsScreen(),
};

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRouter.home:
      return AppRouter.mainScreenRoute(NavigationItem.home);

    case AppRouter.orders:
      return AppRouter.mainScreenRoute(NavigationItem.orders);

    case AppRouter.cart:
      return AppRouter.mainScreenRoute(NavigationItem.cart);

    case AppRouter.explore:
      return AppRouter.mainScreenRoute(NavigationItem.explore);

    case AppRouter.editAddress:
      final locationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => AddressFormScreen(locationId: locationId),
        fullscreenDialog: true,
      );

    case AppRouter.editStore:
      final store = settings.arguments as FoodStore;
      return MaterialPageRoute(
        builder: (_) => VendorStoreFormScreen(existingStore: store),
      );

    case AppRouter.editDish:
      final dishId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => MenuItemFormScreen(dishId: dishId),
        fullscreenDialog: true,
      );

    case AppRouter.googleRegister:
      final args = settings.arguments as Map<String, dynamic>;

      final firstName = args['firstName'] as String;
      final lastName = args['lastName'] as String;
      final email = args['email'] as String;
      return MaterialPageRoute(
        builder:
            (_) => GoogleRegisterScreen(
              firstName: firstName,
              lastName: lastName,
              email: email,
            ),
      );

    case AppRouter.manageDishIngredients:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder:
            (_) => ManageMenuIngredientsScreen(
              dishId: args['dishId'],
              isEditing: args['isEditing'] ?? false,
            ),
        fullscreenDialog: true,
      );

    case AppRouter.notificationSeller:
      return MaterialPageRoute(
        builder: (_) => const VendorNotificationsScreen(),
      );

    default:
      final builder = appRoutes[settings.name];
      if (builder != null) {
        return MaterialPageRoute(builder: builder);
      }
  }
  return null;
}
