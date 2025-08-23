import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

class ChromeCustomTabsService {
  /// Opens a URL in Chrome Custom Tabs (Android only)
  /// Falls back to regular browser on other platforms
  static Future<bool> openUrlInCustomTab(
    BuildContext context,
    String url, {
    Color? primaryColor,
    String? title,
  }) async {
    try {
      developer.log(
        'Attempting to open URL in Chrome Custom Tab: $url',
        name: 'ChromeCustomTabsService',
      );

      // Only use Chrome Custom Tabs on Android
      if (!Platform.isAndroid) {
        developer.log(
          'Platform is not Android, falling back to regular browser',
          name: 'ChromeCustomTabsService',
        );
        return false;
      }

      final Uri uri = Uri.parse(url);

      // Use the app's primary color if not provided
      final Color themeColor = primaryColor ?? const Color(0xFFFF6B35);

      // Launch Chrome Custom Tab
      await launch(
        url,
        customTabsOption: CustomTabsOption(
          toolbarColor: themeColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: CustomTabsSystemAnimation.slideIn(),
          extraCustomTabs: <String>[
            // Add other browsers that support Custom Tabs
            'org.mozilla.firefox',
            'com.microsoft.emmx',
            'com.opera.browser',
          ],
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: themeColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );

      developer.log(
        'Chrome Custom Tab launched successfully',
        name: 'ChromeCustomTabsService',
      );
      return true;
    } catch (e) {
      developer.log(
        'Chrome Custom Tab launch error: $e',
        name: 'ChromeCustomTabsService',
      );
      return false;
    }
  }

  /// Checks if Chrome Custom Tabs are available on the device
  static Future<bool> isCustomTabsAvailable() async {
    try {
      if (!Platform.isAndroid) {
        return false;
      }

      // For Android, assume Chrome Custom Tabs are available
      // The package will handle fallback if Chrome is not installed
      developer.log(
        'Chrome Custom Tabs should be available on Android',
        name: 'ChromeCustomTabsService',
      );
      return true;
    } catch (e) {
      developer.log(
        'Error checking Custom Tabs availability: $e',
        name: 'ChromeCustomTabsService',
      );
      return false;
    }
  }
}
