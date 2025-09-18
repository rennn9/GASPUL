import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/header.dart';
import 'widgets/glass_container.dart';
import 'widgets/menu_card.dart';
import 'widgets/accessibility_menu.dart';
import 'service_page.dart';
import 'home_providers.dart';
import 'package:gaspul/core/data/service_data.dart'; // ✅ ambil data layanan
import 'package:gaspul/core/theme/theme.dart'; // ✅ AppColors

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(accessibilityMenuProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor // ✅ High Contrast → hitam
          : AppColors.primary,            // ✅ Normal → hijau tua
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header
              const Header(),

              // 🔹 Grid dengan glass container belakang
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Stack(
                    children: [
                      const GlassContainer(),

                      GridView.count(
                        padding: const EdgeInsets.all(20),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,

                        // 🔹 Auto-generate MenuCard dari layananData
                        children: layananData.entries.map((entry) {
                          final key = entry.key;
                          final data = entry.value as Map<String, dynamic>;

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

          // 🔹 Popup Accessibility Menu
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
