import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/theme/theme.dart'; // 🔹 import AppColors
import '../home_providers.dart';

class MenuButton extends ConsumerWidget {
  final VoidCallback? onTap; // 🔹 callback dari parent

  const MenuButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.dark
        ? AppColors.menuButtonHighContrastIcon
        : AppColors.menuButtonNormalIcon;

    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      color: AppColors.menuButtonNormalBg,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 🔹 panggil callback dari parent
          if (onTap != null) onTap!();

          // 🔹 update state di provider
          final isOpen = ref.read(accessibilityMenuProvider);
          ref.read(accessibilityMenuProvider.notifier).state = !isOpen;
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.accessible,
            color: iconColor,
            size: 38,
          ),
        ),
      ),
    );
  }
}
