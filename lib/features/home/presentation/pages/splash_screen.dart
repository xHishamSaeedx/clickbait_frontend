import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'urls_page.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/services/url_launcher_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Create scale animation
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Fetch URL from backend and redirect to browser
    Timer(const Duration(seconds: 3), () async {
      try {
        developer.log('Starting redirect process...', name: 'SplashScreen');

        // Fetch the redirect URL from backend
        final redirectUrl = await ApiService.getRedirectUrl();
        developer.log(
          'Fetched URL from backend: $redirectUrl',
          name: 'SplashScreen',
        );

        // Launch the URL using Chrome Custom Tabs (Android) or regular browser (other platforms)
        developer.log(
          'Attempting to launch URL with Custom Tabs...',
          name: 'SplashScreen',
        );

        // Try Chrome Custom Tabs first, with fallback to regular browser
        bool success = await UrlLauncherService.openUrlWithCustomTabs(
          context,
          redirectUrl,
          primaryColor: const Color(0xFFFF6B35), // App's primary color
          title: 'Phone Win', // App title
        );
        developer.log(
          'Custom Tabs launch result: $success',
          name: 'SplashScreen',
        );

        // If Custom Tabs fails, try the regular method as fallback
        if (!success) {
          developer.log('Trying regular URL launch...', name: 'SplashScreen');
          success = await UrlLauncherService.openUrl(redirectUrl);
          developer.log(
            'Regular URL launch result: $success',
            name: 'SplashScreen',
          );
        }

        // If that fails, try the manual method as final fallback
        if (!success) {
          developer.log('Trying manual URL launch...', name: 'SplashScreen');
          success = await UrlLauncherService.openUrlManually(redirectUrl);
          developer.log(
            'Manual URL launch result: $success',
            name: 'SplashScreen',
          );
        }

        if (success) {
          // Show appropriate message based on the launch method
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'URL opened! You can return to the app using the back button',
                ),
                duration: Duration(seconds: 4),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Wait longer for the user to see the Custom Tab or browser
          developer.log(
            'Waiting for user to interact with opened URL...',
            name: 'SplashScreen',
          );
          await Future.delayed(const Duration(seconds: 5));

          developer.log('Navigating to URLs page...', name: 'SplashScreen');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const UrlsPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        } else {
          // If failed to launch URL, show dialog with the URL and navigate to URLs page
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Browser Not Available'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Unable to open browser automatically.'),
                      const SizedBox(height: 10),
                      const Text(
                        'Please copy and paste this URL in your browser:',
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        redirectUrl,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const UrlsPage(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } catch (e) {
        // If API call fails, show error and navigate to URLs page
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const UrlsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6B35),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phone Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        size: 60,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // App Title
                    const Text(
                      'Phone Win',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle
                    const Text(
                      'Your Ultimate Phone Experience',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Loading indicator
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
