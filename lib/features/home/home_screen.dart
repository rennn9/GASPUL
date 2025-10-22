import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/header.dart';
import 'widgets/glass_container.dart';
import 'widgets/menu_card.dart';
import 'widgets/accessibility_menu.dart';
import 'widgets/kemenag_button.dart';
import 'widgets/queue_bottom_sheet.dart';
import 'service_page.dart';
import 'home_providers.dart';
import 'package:gaspul/core/data/service_data.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/routes/no_animation_route.dart';
import 'package:gaspul/core/widgets/gaspul_safe_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showQueueBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const QueueBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(accessibilityMenuProvider);
    final theme = Theme.of(context);

    final kategoriUtama = [
      "publik",
      "internal",
      "kabupaten",
      "pendidikan",
      "kua",
      "rubrik",
      "pengaduan",
    ];

    return GasPulSafeScaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.homeBackgroundHighContrast
          : AppColors.homeBackgroundNormal,
      body: Stack(
        children: [
          Column(
            children: [
              const Header(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 48),
                  child: Stack(
                    children: [
                      const GlassContainer(),
                      GridView.count(
                        padding: const EdgeInsets.all(20),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 16,
                        children: kategoriUtama.map((key) {
                          final data = layananData[key] as Map<String, dynamic>;

                          return MenuCard(
                            title: data["title"],
                            subtitle: data["subtitle"],
                            imagePath: data["image"],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServicePage(
                                    layananKey: key,
                                    title: data["title"],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bar bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? AppColors.homeBottomBarHighContrast
                    : AppColors.homeBottomBarNormal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(80),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.homeBottomBarShadow,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Kemenag
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: const Center(
              child: KemenagButton(),
            ),
          ),

          // Popup Accessibility Menu
          if (isMenuOpen)
            AccessibilityMenu(
              onClose: () {
                ref.read(accessibilityMenuProvider.notifier).state = false;
              },
            ),
        ],
      ),
    );
  }
}
