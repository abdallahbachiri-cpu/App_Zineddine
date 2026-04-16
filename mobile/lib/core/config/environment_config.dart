import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl {
    final isLocal = dotenv.env['ENVIRONMENT'] == 'local';
    return isLocal
        ? (dotenv.env['API_BASE_URL_LOCAL'] ??
            'http://10.0.2.2/cuisinous-backend/public/')
        : (dotenv.env['API_BASE_URL'] ??
            'https://cuisinous-api.onrender.com/');
  }

  static String get stripePublishableKey {
    return dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  }

  static String get stripeMerchantIdentifier {
    return dotenv.env['STRIPE_MERCHANT_IDENTIFIER'] ?? 'ca.cuisinous';
  }

  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  static String get googleSignInClientId {
    return dotenv.env['GOOGLE_SIGN_IN_CLIENT_ID'] ?? '';
  }

  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'production';
  }

  static bool get isLocal {
    return environment == 'local';
  }

  static bool get isDevelopment {
    return environment == 'local' || environment == 'development';
  }
}
