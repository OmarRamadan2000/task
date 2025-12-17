import 'package:firebase_app_distribution/firebase_app_distribution.dart';
import 'package:flutter/material.dart';

/// Service to check for app updates via Firebase App Distribution
class AppUpdateService {
  final FirebaseAppDistribution _appDistribution;

  AppUpdateService({FirebaseAppDistribution? appDistribution})
    : _appDistribution = appDistribution ?? FirebaseAppDistribution.instance;

  /// Check if an update is available and prompt user to update
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Check if tester is signed in
      final isTesterSignedIn = await _appDistribution.isTesterSignedIn();

      if (!isTesterSignedIn) {
        // Sign in tester (will open App Tester login if needed)
        await _appDistribution.signInTester();
      }

      // Check for updates
      final release = await _appDistribution.checkForUpdate();

      if (release != null) {
        // Show update dialog
        if (context.mounted) {
          _showUpdateDialog(context, release);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  void _showUpdateDialog(BuildContext context, AppDistributionRelease release) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(
          'A new version (${release.displayVersion}) is available.\n\n'
          '${release.releaseNotes ?? "Please update to get the latest features and improvements."}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // This will open App Tester to download the update
              _appDistribution.signInTester();
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}
