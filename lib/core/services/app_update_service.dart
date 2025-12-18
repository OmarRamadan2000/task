import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// Service to check for app updates via Firebase Remote Config
class AppUpdateService {
  final FirebaseRemoteConfig _remoteConfig;

  AppUpdateService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  /// Initialize Remote Config with default values and settings
  Future<void> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero, // Use Duration.zero for testing, change to Duration(hours: 1) for production
        ),
      );

      await _remoteConfig.setDefaults({
        'latest_version': currentVersion,
        'latest_build_number': currentBuildNumber,
        'update_url': 'https://appdistribution.firebase.google.com/',
        'force_update': true,
        'release_notes':
            'A new version is available. Please update to get the latest features.',
      });
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  /// Check if an update is available and prompt user
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Fetch latest values from Firebase
      await _remoteConfig.fetchAndActivate();

      final latestVersion = _remoteConfig.getString('latest_version');
      final latestBuildNumber = _remoteConfig.getInt('latest_build_number');
      final updateUrl = _remoteConfig.getString('update_url');
      final forceUpdate = _remoteConfig.getBool('force_update');
      final releaseNotes = _remoteConfig.getString('release_notes');

      // Get current app info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (_isUpdateAvailable(currentBuildNumber, latestBuildNumber)) {
        if (context.mounted) {
          _showUpdateDialog(
            context,
            latestVersion,
            updateUrl,
            forceUpdate,
            releaseNotes,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  /// Compare build numbers to check for update
  bool _isUpdateAvailable(int current, int latest) {
    log('Current build number: $current, Latest build number: $latest');
    return latest > current;
  }

  void _showUpdateDialog(
    BuildContext context,
    String version,
    String url,
    bool force,
    String notes,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (context) => PopScope(
        canPop: !force,
        child: AlertDialog(
          title: const Text('Update Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version $version is now available.'),
              const SizedBox(height: 16),
              Text(notes, style: const TextStyle(fontSize: 14)),
            ],
          ),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }
}
