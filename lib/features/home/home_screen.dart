import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/header.dart';
import 'widgets/glass_container.dart';
import 'widgets/menu_card.dart';
import 'widgets/accessibility_menu.dart';
import 'widgets/kemenag_button.dart';
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

              // 🔹 Grid dengan glass container di belakang
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
                  child: Stack(
                    children: [
                      const GlassContainer(),
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
            ],
          ),

          // 🔹 Bar bawah responsive theme
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 40, // bisa diatur sesuai kebutuhan
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]  // abu-abu gelap saat high contrast
                    : Colors.white,      // putih saat normal
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(80),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Tombol Kemenag (nongol setengah)
          Positioned(
            bottom: 8, // jarak dari bawah → setengah tombol keluar
            left: 0,
            right: 0,
            child: Center(
              child:
                  KemenagButton(), // ukuran tombol tetap, tidak terpengaruh bar
            ),
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
