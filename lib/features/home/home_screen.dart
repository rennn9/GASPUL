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
import 'package:gaspul/features/home/webview_page.dart';

import 'package:gaspul/core/routes/no_animation_route.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(accessibilityMenuProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme
                .scaffoldBackgroundColor // ✅ High Contrast → hitam
          : AppColors.primary, // ✅ Normal → hijau tua
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header
              const Header(),

              // 🔹 Grid dengan glass container belakang
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Stack(
                    children: [
                      const GlassContainer(),

                      // 🔹 Grid menu
                      GridView.count(
                        padding: const EdgeInsets.all(20),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 16,
                        children: layananData.entries.map((entry) {
                          final key = entry.key;
                          final data = entry.value as Map<String, dynamic>;

                          return MenuCard(
                            title: data["title"],
                            subtitle: data["subtitle"],
                            imagePath: data["image"],

                            // 🔹 Aksi klik card
                            onTap: () {
                              if (key == "publik") {
                                Navigator.of(context).push(
                                  NoAnimationRoute(
                                    builder: (context) => WebViewPage(
                                      url: "https://gaspul.com/home",
                                      title: "GASPUL",
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServicePage(
                                      layananKey: key,
                                      title: data["title"],
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Copyright di bagian bawah Scaffold
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.copyright,
                      size: 14,
                      color: Colors.white, // selalu putih
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Sistem Informasi dan Data",
                      style: TextStyle(
                        color: Colors.white, // selalu putih
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
