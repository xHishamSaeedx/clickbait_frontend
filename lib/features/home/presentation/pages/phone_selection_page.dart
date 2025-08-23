import 'package:flutter/material.dart';

class PhoneSelectionPage extends StatefulWidget {
  const PhoneSelectionPage({super.key});

  @override
  State<PhoneSelectionPage> createState() => _PhoneSelectionPageState();
}

class _PhoneSelectionPageState extends State<PhoneSelectionPage> {
  String? selectedPhone;

  final List<PhoneModel> phones = [
    PhoneModel(
      name: 'IPHONE 16',
      imagePath: 'assets/images/iphone16promax.png',
    ),
    PhoneModel(
      name: 'IPHONE 15',
      imagePath: 'assets/images/iphone15promax.png',
    ),
    PhoneModel(
      name: 'IPHONE 14',
      imagePath: 'assets/images/iPhone14promax.png',
    ),
    PhoneModel(
      name: 'IPHONE 13',
      imagePath:
          'assets/images/iphone15promax.png', // Using 15 as placeholder for 13
    ),
    PhoneModel(
      name: 'SAMSUNG S25',
      imagePath: 'assets/images/samsunggalaxys25ultra.png',
    ),
    PhoneModel(
      name: 'SAMSUNG S24',
      imagePath: 'assets/images/samsunggalaxys24ultra.png',
    ),
  ];

  void _onPhoneSelected(String phoneName) {
    setState(() {
      selectedPhone = phoneName;
    });

    // Navigate to next screen or show confirmation
    _showPhoneSelectedDialog(phoneName);
  }

  void _showPhoneSelectedDialog(String phoneName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Phone Selected!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You selected $phoneName. Ready to win?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
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
                              'PHONE WIN',
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
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Please select one phone',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Phone grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: phones.length,
                        itemBuilder: (context, index) {
                          final phone = phones[index];
                          final isSelected = selectedPhone == phone.name;

                          return GestureDetector(
                            onTap: () => _onPhoneSelected(phone.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2d3748,
                                ), // Dark gray background
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFFF6B35),
                                        width: 2,
                                      )
                                    : Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Phone image
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.asset(
                                            phone.imagePath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Phone name
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        phone.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneModel {
  final String name;
  final String imagePath;

  PhoneModel({required this.name, required this.imagePath});
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
