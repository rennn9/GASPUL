import 'package:flutter/material.dart';
import 'package:gaspul/core/widgets/accessible_tap.dart'; // ✅ import

class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AccessibleTap(
      label: "$title, $subtitle", // 🔊 teks yang akan dibaca TTS
      onTap: onTap,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: colors.primary.withOpacity(0.2),
          highlightColor: colors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, height: 60),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                        height: 1.2,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface.withOpacity(0.8),
                        height: 1.2,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
