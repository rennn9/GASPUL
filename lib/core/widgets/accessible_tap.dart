import 'package:flutter/material.dart';
import 'package:gaspul/core/services/tts_service.dart';

class AccessibleTap extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 🔊 baca label dengan TTS
        TTSService().speak(label);

        // kalau ada callback tambahan, jalankan juga
        if (onTap != null) {
          onTap!();
        }
      },
      child: child,
    );
  }
}
