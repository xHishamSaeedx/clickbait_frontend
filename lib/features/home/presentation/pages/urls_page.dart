import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UrlsPage extends StatefulWidget {
  const UrlsPage({super.key});

  @override
  State<UrlsPage> createState() => _UrlsPageState();
}

class _UrlsPageState extends State<UrlsPage> {
  List<Map<String, dynamic>> urls = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUrls();
  }

  Future<void> _fetchUrls() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Backend URL - using your computer's IP address
      const String baseUrl = 'http://192.168.0.104:3000';

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
              '1. Backend server is running on 192.168.0.104:3000\n'
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
                              'URLS',
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

    return Column(
      children: [
        // Header with count
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2d3748).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.link, color: Color(0xFF64b5f6), size: 24),
              const SizedBox(width: 12),
              Text(
                '${urls.length} URLs Found',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _fetchUrls,
                icon: const Icon(Icons.refresh, color: Color(0xFF64b5f6)),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // URLs list
        Expanded(
          child: ListView.builder(
            itemCount: urls.length,
            itemBuilder: (context, index) {
              final urlData = urls[index];
              return _buildUrlCard(urlData, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUrlCard(Map<String, dynamic> urlData, int index) {
    final String url = urlData['url'] ?? 'No URL';
    final String id = urlData['id'] ?? 'Unknown ID';
    final bool isActive = urlData['active'] ?? true;
    final String? createdAt = urlData['createdAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3748).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFF64b5f6).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF64b5f6).withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: isActive ? const Color(0xFF64b5f6) : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${id.substring(0, 8)}...',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // URL content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: SelectableText(
              url,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
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
