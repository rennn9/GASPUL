import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/features/home/widgets/menu_button.dart';
import 'package:gaspul/features/home/widgets/accessibility_menu.dart';
import 'package:gaspul/features/home/home_providers.dart';

/// AppBar utama yang bisa digunakan di seluruh halaman.
/// Menyediakan tombol back, title dinamis, dan menu aksesibilitas.
class MainAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const MainAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  ConsumerState<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _MainAppBarState extends ConsumerState<MainAppBar> {
  OverlayEntry? _accessibilityOverlay;

  void _showAccessibilityMenu() {
    if (_accessibilityOverlay != null) return;
    _accessibilityOverlay = OverlayEntry(
      builder: (context) => AccessibilityMenu(
        top: 28,
        right: 12,
        bottom: null,
        onClose: _removeAccessibilityMenu,
      ),
    );
    Overlay.of(context).insert(_accessibilityOverlay!);
  }

  void _removeAccessibilityMenu() {
    _accessibilityOverlay?.remove();
    _accessibilityOverlay = null;
    ref.read(accessibilityMenuProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.brightness == Brightness.dark;

    return AppBar(
      leading: widget.showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        widget.title,
        style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
      ),
      backgroundColor: isHighContrast ? Colors.black : AppColors.primary,
      centerTitle: false,
      toolbarHeight: 80,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: MenuButton(
            onTap: () {
              final isOpen = ref.read(accessibilityMenuProvider);
              if (isOpen) {
                _removeAccessibilityMenu();
              } else {
                _showAccessibilityMenu();
                ref.read(accessibilityMenuProvider.notifier).state = true;
              }
            },
          ),
        ),
      ],
      bottom: isHighContrast
          ? const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.white),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _accessibilityOverlay?.remove();
    super.dispose();
  }
}
