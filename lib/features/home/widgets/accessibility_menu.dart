import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'accessibility_provider.dart';

// 🔹 Service TTS global
class TtsService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
    await _tts.setLanguage("id-ID");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  static Future<void> stop() async => _tts.stop();
}

class AccessibilityMenu extends ConsumerWidget {
  final VoidCallback onClose;

  const AccessibilityMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : AppColors.primary;

    final closeIconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : AppColors.primary;

    final readContent = ref.watch(accessibilityProvider).readContent;

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withOpacity(0)),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Material(
              color: Colors.transparent,
              elevation: 100,
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, size: 28, color: closeIconColor),
                      onPressed: () {
                        if (readContent) TtsService.speak("Tutup menu");
                        onClose();
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuButton(
                          icon: Icons.brightness_6,
                          label: "Kontras\nTinggi",
                          backgroundColor: buttonColor,
                          readContent: readContent,
                          onTap: () {
                            ref.read(accessibilityProvider.notifier).toggleHighContrast();
                          },
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          icon: Icons.format_size,
                          label: "Teks\nBesar",
                          backgroundColor: buttonColor,
                          readContent: readContent,
                          onTap: () {
                            ref.read(accessibilityProvider.notifier).toggleLargeText();
                          },
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          icon: Icons.volume_up,
                          label: "Baca\nKonten",
                          backgroundColor: buttonColor,
                          readContent: readContent,
                          onTap: () {
                            ref.read(accessibilityProvider.notifier).toggleReadContent();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final bool readContent; // 🔹 apakah fitur baca konten aktif

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.readContent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (readContent) {
            // baca label, hapus newline agar enak dibaca
            TtsService.speak(label.replaceAll('\n', ' '));
          }
          if (onTap != null) onTap!();
        },
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: 100,
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
