import 'package:flutter/material.dart';
import '../config/environment_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConsts {
  AppConsts._();

  static String get apiBaseUrl => EnvironmentConfig.apiBaseUrl;
  static bool get isLocal => EnvironmentConfig.isLocal;

  static const Color accentColor = Color(0xFFF53939);
  static const Color secondaryAccentColor = Color(0xff347928);
  static const Color backgroundColor = Color(0xFFFFEFE0);

  static const Color primaryColor = Colors.black;
  static const Color secondaryTextColor = Colors.black;

  static const defaultMapLocation = LatLng(45.5017, -73.5673);
}
