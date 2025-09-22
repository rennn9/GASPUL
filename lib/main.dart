// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/features/home/home_screen.dart';
import 'package:gaspul/features/home/splash_first.dart'; // ✅ splash page pertama
import 'package:gaspul/features/home/widgets/accessibility_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return MaterialApp(
      title: 'GASPUL',
      debugShowCheckedModeBanner: false,
      theme: accessibility.highContrast
          ? AppTheme.highContrastTheme
          : AppTheme.lightTheme,
      home: const SplashFirst(), // ✅ tampilkan splash page pertama
    );
  }
}
