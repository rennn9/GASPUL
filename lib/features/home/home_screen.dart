import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/header.dart';
import 'widgets/glass_container.dart';
import 'widgets/menu_card.dart';
import 'widgets/accessibility_menu.dart';

// 🔹 Provider untuk kontrol popup menu
final menuOpenProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF017787);
    const secondaryColor = Color(0xFF05A4AD);

    final isMenuOpen = ref.watch(menuOpenProvider);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header
              Header(
                onMenuPressed: () {
                  ref.read(menuOpenProvider.notifier).state = true;
                },
              ),

              // 🔹 Grid dengan glass container belakang
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Stack(
                    children: [
                      const GlassContainer(),

                      GridView.count(
                        padding: const EdgeInsets.all(20),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          MenuCard(
                            title: "Layanan Publik",
                            subtitle: "Pelayanan untuk Masyarakat",
                            imagePath:
                                "assets/images/Logo Pelayanan Publik.png",
                            secondaryColor: secondaryColor,
                          ),
                          MenuCard(
                            title: "Layanan Internal",
                            subtitle: "Sistem Internal Organisasi",
                            imagePath:
                                "assets/images/Logo Layanan Internal.png",
                            secondaryColor: secondaryColor,
                          ),
                          MenuCard(
                            title: "Layanan Kabupaten",
                            subtitle: "Layanan Tingkat Daerah",
                            imagePath:
                                "assets/images/Logo Layanan Kabupaten.png",
                            secondaryColor: secondaryColor,
                          ),
                          MenuCard(
                            title: "Layanan Pendidikan",
                            subtitle: "Layanan Pendidikan",
                            imagePath:
                                "assets/images/Logo Layanan Pendidikan.png",
                            secondaryColor: secondaryColor,
                          ),
                          MenuCard(
                            title: "Layanan KUA",
                            subtitle: "Kantor Urusan Agama",
                            imagePath: "assets/images/Logo KUA.png",
                            secondaryColor: secondaryColor,
                          ),
                          MenuCard(
                            title: "Rubrik",
                            subtitle: "Informasi dan Berita",
                            imagePath: "assets/images/Logo Rubrik.png",
                            secondaryColor: secondaryColor,
                          ),
                        ],
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
                ref.read(menuOpenProvider.notifier).state = false;
              },
            ),
        ],
      ),
    );
  }
}
