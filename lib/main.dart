import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'features/home/presentation/pages/start_page.dart';
import 'features/home/presentation/pages/phone_selection_page.dart';

void main() {
  // Disable debug paint bounds
  debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Win',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B35)),
        useMaterial3: true,
      ),
      home: const StartPage(),
    );
  }
}
