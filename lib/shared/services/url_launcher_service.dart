import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class UrlLauncherService {
  /// Launches a URL in the default browser
  static Future<bool> openUrl(String url) async {
    try {
      developer.log(
        'Attempting to launch URL: $url',
        name: 'UrlLauncherService',
      );

      final Uri uri = Uri.parse(url);
      developer.log('Parsed URI: $uri', name: 'UrlLauncherService');

      // Check if URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      developer.log('Can launch URL: $canLaunch', name: 'UrlLauncherService');

      if (canLaunch) {
        bool success = false;

        // For Android, use a more reliable approach
        if (Platform.isAndroid) {
          try {
            // On Android, try to launch with a slight delay to ensure proper intent handling
            await Future.delayed(const Duration(milliseconds: 100));

            // Try with external application mode
            success = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            developer.log(
              'Android external launch result: $success',
              name: 'UrlLauncherService',
            );

            // If external fails, try platform default
            if (!success) {
              await Future.delayed(const Duration(milliseconds: 200));
              success = await launchUrl(uri, mode: LaunchMode.platformDefault);
              developer.log(
                'Android platform launch result: $success',
                name: 'UrlLauncherService',
              );
            }

            // If still fails, try in-app browser as last resort
            if (!success) {
              await Future.delayed(const Duration(milliseconds: 200));
              success = await launchUrl(uri, mode: LaunchMode.inAppWebView);
              developer.log(
                'Android in-app launch result: $success',
                name: 'UrlLauncherService',
              );
            }
          } catch (e) {
            developer.log(
              'Android launch error: $e',
              name: 'UrlLauncherService',
            );
          }
        } else {
          // For iOS and other platforms
          try {
            success = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            developer.log(
              'Non-Android launch result: $success',
              name: 'UrlLauncherService',
            );
          } catch (e) {
            developer.log(
              'Non-Android launch error: $e',
              name: 'UrlLauncherService',
            );
          }
        }

        return success;
      } else {
        developer.log('Cannot launch URL: $url', name: 'UrlLauncherService');
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      developer.log('URL launch error: $e', name: 'UrlLauncherService');
      throw Exception('Failed to launch URL: $e');
    }
  }

  /// Manual URL opening method for Android
  static Future<bool> openUrlManually(String url) async {
    try {
      developer.log(
        'Attempting manual URL launch: $url',
        name: 'UrlLauncherService',
      );

      final Uri uri = Uri.parse(url);

      // Try multiple times with different approaches
      for (int i = 0; i < 3; i++) {
        try {
          developer.log(
            'Manual launch attempt ${i + 1}',
            name: 'UrlLauncherService',
          );

          final success = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (success) {
            developer.log(
              'Manual launch successful on attempt ${i + 1}',
              name: 'UrlLauncherService',
            );
            return true;
          }

          // Wait between attempts
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          developer.log(
            'Manual launch attempt ${i + 1} failed: $e',
            name: 'UrlLauncherService',
          );
        }
      }

      return false;
    } catch (e) {
      developer.log('Manual URL launch error: $e', name: 'UrlLauncherService');
      return false;
    }
  }

  /// Checks if a URL can be launched
  static Future<bool> canOpenUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } catch (e) {
      developer.log('Can launch check error: $e', name: 'UrlLauncherService');
      return false;
    }
  }
}
