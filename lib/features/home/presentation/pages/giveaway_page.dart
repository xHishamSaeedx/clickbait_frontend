import 'package:flutter/material.dart';
import 'urls_page.dart';

class GiveawayPage extends StatelessWidget {
  final String phoneName;

  const GiveawayPage({super.key, required this.phoneName});

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
                        const Expanded(
                          child: Center(
                            child: Text(
                              'GIVEAWAY',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64b5f6), // Light blue color
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // How to Win Section
                          _buildSection(
                            icon: Icons.flash_on,
                            iconColor: const Color(0xFF2196F3),
                            title: 'How to Win',
                            description:
                                'Share the app with 5 friends and complete the task.',
                            showDivider: true,
                          ),
                          const SizedBox(height: 20),

                          // Phone Delivery Section
                          _buildSection(
                            icon: Icons.local_shipping,
                            iconColor: const Color(0xFF64B5F6),
                            title: 'Phone Delivery',
                            description:
                                'If you win, the phone will be delivered to your address within 7 days.',
                            showDivider: true,
                          ),
                          const SizedBox(height: 20),

                          // Terms & Conditions Section
                          _buildSection(
                            icon: Icons.description,
                            iconColor: const Color(0xFF64B5F6),
                            title: 'Terms & Conditions',
                            description:
                                'Not everyone will receive a phone – only a few lucky users will be selected. ',
                            showDivider: false,
                            hasMoreLink: true,
                          ),

                          const Spacer(),

                          // Call to Action Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2196F3,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: () {
                                  // Navigate to URLs page
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const UrlsPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'GET $phoneName',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
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

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool showDivider,
    bool hasMoreLink = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3748).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: description),
                          if (hasMoreLink)
                            const TextSpan(
                              text: 'MORE.',
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 16),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ],
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
