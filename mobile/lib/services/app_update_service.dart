import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  final FirebaseRemoteConfig _remoteConfig;

  AppUpdateService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setDefaults(<String, dynamic>{
      'latest_version': '1.0.9',
      'minimum_version': '1.0.9',
      'force_update': false,
      'android_update_url': 'https://play.google.com/store/apps/details?id=ca.cuisinous',
      'ios_update_url': 'https://apps.apple.com/app/idYOUR_APP_ID',
    });

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 6),
      ),
    );

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Ignore failures: app should continue normally if remote config cannot fetch.
    }
  }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final latestVersion = _remoteConfig.getString('latest_version');
      final minimumVersion = _remoteConfig.getString('minimum_version');
      final forceUpdate = _remoteConfig.getBool('force_update');
      final updateUrl = _getUpdateUrl();

      final isUpdateAvailable = _compareVersion(currentVersion, latestVersion) < 0;
      final isForcedUpdate = _compareVersion(currentVersion, minimumVersion) < 0 || forceUpdate;

      if (isUpdateAvailable) {
        await _showUpdateDialog(
          context,
          isForced: isForcedUpdate,
          updateUrl: updateUrl,
          latestVersion: latestVersion,
          currentVersion: currentVersion,
        );
      }
    } catch (_) {
      // No-op: if anything fails, do not block app startup.
    }
  }

  String _getUpdateUrl() {
    if (Platform.isAndroid) {
      return _remoteConfig.getString('android_update_url') ??
          'https://play.google.com/store/apps/details?id=ca.cuisinous';
    }
    return _remoteConfig.getString('ios_update_url') ??
        'https://apps.apple.com/app/idYOUR_APP_ID';
  }

  Future<void> _showUpdateDialog(
    BuildContext context, {
    required bool isForced,
    required String updateUrl,
    required String latestVersion,
    required String currentVersion,
  }) async {
    final title = isForced ? 'Update Required' : 'Update Available';
    final message = isForced
        ? 'A newer version ($latestVersion) is required to continue using the app. Please update now.'
        : 'A newer version ($latestVersion) is available. Update now to get the latest features and fixes.';

    await showDialog<void>(
      context: context,
      barrierDismissible: !isForced,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 12),
              Text('Installed: $currentVersion', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Latest: $latestVersion', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: <Widget>[
            if (!isForced)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
            TextButton(
              onPressed: () {
                _launchUrl(updateUrl);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  int _compareVersion(String a, String b) {
    final aParts = a.split('.').map(int.tryParse).map((value) => value ?? 0).toList();
    final bParts = b.split('.').map(int.tryParse).map((value) => value ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final aValue = i < aParts.length ? aParts[i] : 0;
      final bValue = i < bParts.length ? bParts[i] : 0;
      if (aValue != bValue) {
        return aValue.compareTo(bValue);
      }
    }
    return 0;
  }
}
