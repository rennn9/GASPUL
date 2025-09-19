import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/services/tts_service.dart';
import 'package:gaspul/features/home/widgets/accessibility_provider.dart';

class AccessibleTap extends ConsumerWidget {
  final Widget child;
  final String label;
  final VoidCallback? onTap;

  const AccessibleTap({
    super.key,
    required this.child,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readContent = ref.watch(accessibilityProvider).readContent;

    return GestureDetector(
      onTap: () {
        // 🔊 hanya bicara jika fitur Baca Konten aktif
        if (readContent) {
          TTSService().speak(label);
        }

        // kalau ada callback tambahan, jalankan juga
        if (onTap != null) {
          onTap!();
        }
      },
      child: child,
    );
  }
}
