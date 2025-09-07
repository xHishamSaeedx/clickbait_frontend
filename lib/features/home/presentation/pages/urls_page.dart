import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../../shared/services/url_launcher_service.dart';

class UrlsPage extends StatefulWidget {
  const UrlsPage({super.key});

  @override
  State<UrlsPage> createState() => _UrlsPageState();
}

class _UrlsPageState extends State<UrlsPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> urls = [];
  bool isLoading = true;
  String? error;

  // Timer-related state
  Timer? _timer;
  int _remainingSeconds = 40;
  bool _isTimerActive = false;
  String? _activeUrlId;
  String? _activeUrl;
  Map<String, bool> _completedUrls = {};

  // Simple pause state - when user closes tab
  bool _isTimerPaused = false;

  // Flag to prevent immediate pausing when URL opens
  bool _justStartedTimer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUrls();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('=== APP LIFECYCLE STATE CHANGED ===');
    print('New state: $state');
    print(
      '_isTimerActive: $_isTimerActive, _isTimerPaused: $_isTimerPaused, _justStartedTimer: $_justStartedTimer',
    );

    // Only handle timer if it's active and not already paused
    if (_isTimerActive && !_isTimerPaused) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          // Don't pause immediately if we just started the timer (URL opening)
          if (_justStartedTimer) {
            print('Just started timer, not pausing immediately');
            // Reset the flag after a short delay
            Timer(const Duration(seconds: 2), () {
              _justStartedTimer = false;
              print('Reset _justStartedTimer flag');
            });
          } else {
            print('Pausing timer - user closed tab');
            _pauseTimer();
          }
          break;
        case AppLifecycleState.resumed:
          // User returned to app - show resume dialog if timer was paused
          print('App resumed - checking if timer is paused');
          if (_isTimerPaused) {
            print('Timer is paused, showing resume dialog');
            _showResumeDialog();
          } else {
            print('Timer is not paused, no resume dialog needed');
          }
          break;
      }
    }
  }

  Future<void> _fetchUrls() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Backend URL - using your computer's IP address
      const String baseUrl = 'http://192.168.0.102:3000';

      print('Attempting to fetch URLs from: $baseUrl/api/urls');

      final response = await http.get(
        Uri.parse('$baseUrl/api/urls'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          urls = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load URLs: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching URLs: $e');
      setState(() {
        if (e.toString().contains('Connection refused') ||
            e.toString().contains('SocketException')) {
          error =
              'Cannot connect to backend server.\n\n'
              'Make sure:\n'
              '1. Backend server is running on 192.168.0.102:3000\n'
              '2. Your device and computer are on the same network\n'
              '3. Firewall allows connections on port 3000\n\n'
              'Error: $e';
        } else {
          error = 'Error: $e';
        }
        isLoading = false;
      });
    }
  }

  void _startTimer(String urlId, String url) {
    print('=== _startTimer METHOD CALLED ===');
    print('URL ID: $urlId');
    print('URL: $url');
    print(
      'Current state before: _isTimerActive=$_isTimerActive, _remainingSeconds=$_remainingSeconds',
    );

    // Cancel any existing timer
    _timer?.cancel();
    print('Existing timer cancelled');

    setState(() {
      _isTimerActive = true;
      _remainingSeconds = 40;
      _activeUrlId = urlId;
      _activeUrl = url;
      _isTimerPaused = false;
      _justStartedTimer = true; // Set flag to prevent immediate pausing
    });
    print(
      'State updated: _isTimerActive=$_isTimerActive, _remainingSeconds=$_remainingSeconds, _justStartedTimer=$_justStartedTimer',
    );
    print('About to create Timer.periodic...');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('Timer tick: _remainingSeconds = $_remainingSeconds');
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        print('Timer decremented to: $_remainingSeconds');
      } else {
        print('Timer reached 0, calling _completeTimer');
        _completeTimer();
      }
    });

    print('=== Timer.periodic CREATED ===');
    print('Timer should now be running with 40 seconds remaining');
  }

  void _completeTimer() {
    print('Timer completed!');
    _timer?.cancel();

    // Mark URL as completed
    if (_activeUrlId != null) {
      _completedUrls[_activeUrlId!] = true;
    }

    // Reset timer state
    setState(() {
      _isTimerActive = false;
      _remainingSeconds = 40;
      _activeUrlId = null;
      _activeUrl = null;
      _isTimerPaused = false;
      _justStartedTimer = false;
    });

    _showCompletionDialog();
  }

  void _stopTimer() {
    print('Timer stopped by user');
    _timer?.cancel();
    setState(() {
      _isTimerActive = false;
      _remainingSeconds = 40;
      _activeUrlId = null;
      _activeUrl = null;
      _isTimerPaused = false;
      _justStartedTimer = false;
    });
  }

  void _pauseTimer() {
    print('=== _pauseTimer CALLED ===');
    print('_isTimerActive: $_isTimerActive, _isTimerPaused: $_isTimerPaused');
    if (_isTimerActive && !_isTimerPaused) {
      print('Pausing timer - user closed tab');
      _timer?.cancel();
      setState(() {
        _isTimerPaused = true;
      });
      print('Timer paused successfully');
    } else {
      print('Timer not paused - conditions not met');
    }
  }

  void _resumeTimer() {
    print('=== _resumeTimer CALLED ===');
    print(
      '_isTimerActive: $_isTimerActive, _isTimerPaused: $_isTimerPaused, _activeUrl: $_activeUrl',
    );
    if (_isTimerActive && _isTimerPaused && _activeUrl != null) {
      print('Resuming timer - reopening URL');
      _openUrlAndResumeTimer(_activeUrl!);
    } else {
      print('Cannot resume timer - conditions not met');
    }
  }

  Future<void> _openUrlAndResumeTimer(String url) async {
    print('=== _openUrlAndResumeTimer CALLED ===');
    print('URL to reopen: $url');
    print(
      'Current state: _isTimerActive=$_isTimerActive, _isTimerPaused=$_isTimerPaused, _remainingSeconds=$_remainingSeconds',
    );
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64b5f6)),
            ),
          );
        },
      );

      // Try to open URL with custom Chrome tabs
      bool success = await UrlLauncherService.openUrlWithCustomTabs(
        context,
        url,
        primaryColor: const Color(0xFF64b5f6),
        title: 'Phone Win',
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Resume the timer - continue from where it was paused
        print('=== URL REOPENED SUCCESSFULLY ===');
        print('Resuming timer from $_remainingSeconds seconds');
        setState(() {
          _isTimerPaused = false;
          _justStartedTimer =
              true; // Set flag to prevent immediate pausing when URL opens
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_remainingSeconds > 0) {
            setState(() {
              _remainingSeconds--;
            });
          } else {
            _completeTimer();
          }
        });

        // Reset the _justStartedTimer flag after a delay to allow normal pausing behavior
        Timer(const Duration(seconds: 2), () {
          _justStartedTimer = false;
          print('Reset _justStartedTimer flag after resume');
        });

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'URL reopened! Timer resumed - stay on the page until completion',
              ),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // If custom tabs fail, try regular URL launcher
        success = await UrlLauncherService.openUrl(url);

        if (success) {
          // Resume the timer
          setState(() {
            _isTimerPaused = false;
            _justStartedTimer =
                true; // Set flag to prevent immediate pausing when URL opens
          });

          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_remainingSeconds > 0) {
              setState(() {
                _remainingSeconds--;
              });
            } else {
              _completeTimer();
            }
          });

          // Reset the _justStartedTimer flag after a delay to allow normal pausing behavior
          Timer(const Duration(seconds: 2), () {
            _justStartedTimer = false;
            print('Reset _justStartedTimer flag after resume (fallback)');
          });

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'URL reopened in browser! Timer resumed - stay on the page until completion',
                ),
                duration: Duration(seconds: 4),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Show error dialog with URL to copy
          if (context.mounted) {
            _showUrlErrorDialog(context, url);
          }
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
        _showUrlErrorDialog(context, url);
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Task Completed!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Congratulations! You have successfully completed the 40-second task. You can now proceed to the next URL or continue with other tasks.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continue',
                style: TextStyle(color: Color(0xFF64b5f6)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResumeDialog() {
    print('=== _showResumeDialog CALLED ===');
    print(
      'Current state: _isTimerActive=$_isTimerActive, _isTimerPaused=$_isTimerPaused, _remainingSeconds=$_remainingSeconds',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.pause_circle, color: Color(0xFF64b5f6)),
              SizedBox(width: 8),
              Text(
                'Timer Paused',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The timer was paused when you left the app.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                'Time remaining: ${_formatTime(_remainingSeconds)}',
                style: const TextStyle(
                  color: Color(0xFF64b5f6),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Would you like to resume the timer?',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('Cancel Timer button pressed');
                Navigator.of(context).pop();
                _stopTimer();
              },
              child: const Text(
                'Cancel Timer',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                print('Resume Timer button pressed');
                Navigator.of(context).pop();
                _resumeTimer();
              },
              child: const Text(
                'Resume Timer',
                style: TextStyle(color: Color(0xFF64b5f6)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTimerDisplay() {
    print('=== _buildTimerDisplay CALLED ===');
    print(
      '_isTimerActive: $_isTimerActive, _isTimerPaused: $_isTimerPaused, _remainingSeconds: $_remainingSeconds',
    );
    print('Timer display will show: ${_isTimerPaused ? "PAUSED" : "ACTIVE"}');
    final progress = (40 - _remainingSeconds) / 40;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3748).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isTimerPaused
              ? Colors.orange.withOpacity(0.5)
              : const Color(0xFF64b5f6).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isTimerPaused ? Colors.orange : const Color(0xFF64b5f6))
                .withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isTimerPaused ? Icons.pause_circle : Icons.timer,
                color: _isTimerPaused ? Colors.orange : const Color(0xFF64b5f6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _isTimerPaused ? 'Timer Paused' : 'Timer Active',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  color: _isTimerPaused
                      ? Colors.orange
                      : const Color(0xFF64b5f6),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isTimerPaused
                        ? [Colors.orange, Colors.deepOrange]
                        : [const Color(0xFF64b5f6), const Color(0xFF42a5f5)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isTimerPaused
                      ? 'Timer paused - return to the app to resume'
                      : 'Stay on the current page until the timer completes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Black at top
              Color(0xFF1a1a2e), // Dark blue at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(painter: BackgroundPatternPainter()),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Top banner image
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/freefirebanner.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF64b5f6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF64b5f6).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    color: Color(0xFF64b5f6),
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Banner Image',
                                    style: TextStyle(
                                      color: Color(0xFF64b5f6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Timer display
                  if (_isTimerActive || _isTimerPaused) _buildTimerDisplay(),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64b5f6)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading URLs...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUrls,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64b5f6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (urls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(
              'No URLs found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There are no URLs available at the moment.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final urlData = urls[index];
        return _buildUrlCard(urlData, index);
      },
    );
  }

  Widget _buildUrlCard(Map<String, dynamic> urlData, int index) {
    final String url = urlData['url'] ?? 'No URL';
    final String id = urlData['id'] ?? 'Unknown ID';
    final bool isActive = urlData['active'] ?? true;
    final bool isCompleted = _completedUrls[id] ?? false;
    final bool isCurrentlyActive = _activeUrlId == id;
    final bool isCurrentlyPaused = isCurrentlyActive && _isTimerPaused;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3748).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Orange accent bar
          Container(
            width: 6,
            height: 100,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isCurrentlyPaused
                  ? Colors.orange
                  : isCurrentlyActive
                  ? const Color(0xFF64b5f6)
                  : Colors.orange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Step indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isCurrentlyPaused
                          ? Colors.orange
                          : isCurrentlyActive
                          ? const Color(0xFF64b5f6)
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Instructions text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visit and wait for 40 seconds',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green
                                : isCurrentlyPaused
                                ? Colors.orange
                                : isCurrentlyActive
                                ? const Color(0xFF64b5f6)
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stay active on this page',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Open button
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : isCurrentlyPaused
                        ? _resumeTimer
                        : isCurrentlyActive
                        ? null // Disable if this is the active timer
                        : (_isTimerActive || _isTimerPaused)
                        ? null // Disable if any timer is active or paused
                        : () => _visitUrlWithTimer(url, id, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.green
                          : isCurrentlyPaused
                          ? Colors.orange
                          : isCurrentlyActive
                          ? const Color(0xFF64b5f6)
                          : (_isTimerActive || _isTimerPaused)
                          ? Colors.grey.withOpacity(0.6)
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      isCompleted
                          ? 'Completed'
                          : isCurrentlyPaused
                          ? 'Resume'
                          : isCurrentlyActive
                          ? 'Active'
                          : (_isTimerActive || _isTimerPaused)
                          ? 'Busy'
                          : 'Open',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _visitUrlWithTimer(
    String url,
    String urlId,
    BuildContext context,
  ) async {
    print('=== _visitUrlWithTimer CALLED ===');
    print('URL: $url');
    print('ID: $urlId');
    print(
      'Current timer state: _isTimerActive=$_isTimerActive, _remainingSeconds=$_remainingSeconds',
    );

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64b5f6)),
            ),
          );
        },
      );

      // Try to open URL with custom Chrome tabs
      bool success = await UrlLauncherService.openUrlWithCustomTabs(
        context,
        url,
        primaryColor: const Color(0xFF64b5f6),
        title: 'Phone Win',
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        print('=== URL OPENED SUCCESSFULLY ===');
        print('About to call _startTimer with urlId: $urlId, url: $url');
        // Start the timer after successful URL opening
        _startTimer(urlId, url);
        print('=== _startTimer CALLED ===');

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'URL opened! Timer started - stay on the page for 40 seconds',
              ),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // If custom tabs fail, try regular URL launcher
        success = await UrlLauncherService.openUrl(url);

        if (success) {
          print('=== URL OPENED SUCCESSFULLY (FALLBACK) ===');
          print('About to call _startTimer with urlId: $urlId, url: $url');
          // Start the timer after successful URL opening
          _startTimer(urlId, url);
          print('=== _startTimer CALLED (FALLBACK) ===');

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'URL opened in browser! Timer started - stay on the page for 40 seconds',
                ),
                duration: Duration(seconds: 4),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Show error dialog with URL to copy
          if (context.mounted) {
            _showUrlErrorDialog(context, url);
          }
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
        _showUrlErrorDialog(context, url);
      }
    }
  }

  void _showUrlErrorDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Cannot Open URL'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Unable to open the URL automatically.'),
              const SizedBox(height: 12),
              const Text(
                'Please copy and paste this URL in your browser:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle dots in a hexagonal pattern
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Create hexagonal grid of dots
    final spacing = 80.0;
    final rows = (size.height / spacing).ceil() + 2;
    final cols = (size.width / spacing).ceil() + 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = col * spacing + (row % 2) * (spacing / 2);
        final y = row * spacing * 0.866; // Hexagonal spacing

        if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
          // Draw dot
          canvas.drawCircle(Offset(x, y), 1.5, dotPaint);

          // Connect to neighboring dots
          final neighbors = [
            Offset(x + spacing, y),
            Offset(x + spacing / 2, y + spacing * 0.866),
            Offset(x - spacing / 2, y + spacing * 0.866),
          ];

          for (final neighbor in neighbors) {
            if (neighbor.dx >= 0 &&
                neighbor.dx <= size.width &&
                neighbor.dy >= 0 &&
                neighbor.dy <= size.height) {
              canvas.drawLine(Offset(x, y), neighbor, linePaint);
            }
          }
        }
      }
    }

    // Add subtle gradient circles in corners
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.03), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 100));

    canvas.save();
    canvas.translate(0, 0);
    canvas.drawCircle(Offset(0, 0), 100, gradientPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width, 0);
    canvas.drawCircle(Offset(0, 0), 100, gradientPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(0, size.height);
    canvas.drawCircle(Offset(0, 0), 100, gradientPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.drawCircle(Offset(0, 0), 100, gradientPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
