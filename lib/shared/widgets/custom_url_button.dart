import 'package:flutter/material.dart';
import '../services/url_launcher_service.dart';

class CustomUrlButton extends StatelessWidget {
  final String url;
  final String buttonText;
  final Color? primaryColor;
  final String? title;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const CustomUrlButton({
    super.key,
    required this.url,
    required this.buttonText,
    this.primaryColor,
    this.title,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _openUrl(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor ?? const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    try {
      final success = await UrlLauncherService.openUrlWithCustomTabs(
        context,
        url,
        primaryColor: primaryColor,
        title: title,
      );

      if (success) {
        onSuccess?.call();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('URL opened successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        onError?.call();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to open URL'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      onError?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
