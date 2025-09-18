import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/theme/theme.dart'; // 🔹 import AppColors
import '../home_providers.dart';

class MenuButton extends ConsumerWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 pilih warna ikon berdasarkan tema
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black       // High Contrast
        : AppColors.secondary; // Normal

    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 4, // 🔹 shadow agar mirip di Header
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final isOpen = ref.read(accessibilityMenuProvider);
          ref.read(accessibilityMenuProvider.notifier).state = !isOpen;
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.menu,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}
