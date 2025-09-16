import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(
    const ProviderScope( // 🔹 Riverpod wajib pakai ini
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaspul',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // 🔹 pakai theme dari theme.dart
      home: const HomeScreen(),
    );
  }
}
