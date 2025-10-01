import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:gaspul/features/home/widgets/accessibility_provider.dart';

class ComingSoonPage extends ConsumerWidget {
  final String title;

  const ComingSoonPage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final highContrast = ref.watch(accessibilityProvider).highContrast;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/Under_Maintenance.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 20),
            Text(
              'Fitur "$title" sedang dalam pengembangan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Silakan tunggu pembaruan berikutnya.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: highContrast ? Colors.white : Colors.transparent, // 🔹 efek stroke
                    width: highContrast ? 2 : 0,
                  ),
                ),
              ),
              child: const Text(
                "Kembali",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
