import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool _isLoading = false;

  void _onGetStartedPressed() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate to next screen or show dialog
        _showComingSoonDialog();
      }
    });
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Coming Soon!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'The full Phone Win experience is coming soon. Stay tuned for exciting updates!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFFFF6B35))),
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
                  const SizedBox(height: 60),
                  // Phone images section
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ring effect around phone
                          Container(
                            width: 400,
                            height: 400,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          // Single large phone image
                          Transform.rotate(
                            angle: 0.05,
                            child: Container(
                              width: 200,
                              height: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  'assets/images/iphone16promax.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Text content section
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main title
                          const Text(
                            'PHONE WIN',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Tagline
                          const Text(
                            'Win Free Phones, Every Day!\nSimple, Fast, and Fun!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Navigation dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Get Started button
                          CustomButton(
                            text: 'Get Started',
                            onPressed: _onGetStartedPressed,
                            isLoading: _isLoading,
                            gradientColors: const [
                              Color(0xFFFF6B35),
                              Color(0xFFFF8E53),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
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
