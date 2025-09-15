import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/header.dart';
import 'widgets/glass_container.dart';
import 'widgets/menu_card.dart';
import 'widgets/accessibility_menu.dart';
import 'service_page.dart';
import 'home_providers.dart'; // 🔹 akses accessibilityMenuProvider

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF017787);
    const secondaryColor = Color(0xFF05A4AD);

    final isMenuOpen = ref.watch(accessibilityMenuProvider);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header
              const Header(),

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
                            imagePath: "assets/images/Logo Pelayanan Publik.png",
                            secondaryColor: secondaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicePage(
                                    title: "Layanan Publik",
                                    subtitle: "Pelayanan untuk Masyarakat",
                                    imagePath:
                                        "assets/images/Logo Pelayanan Publik.png",
                                    items: [],
                                  ),
                                ),
                              );
                            },
                          ),
                          MenuCard(
                            title: "Layanan Internal",
                            subtitle: "Sistem Internal Organisasi",
                            imagePath: "assets/images/Logo Layanan Internal.png",
                            secondaryColor: secondaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicePage(
                                    title: "Layanan Internal",
                                    subtitle: "Sistem Internal Organisasi",
                                    imagePath:
                                        "assets/images/Logo Layanan Internal.png",
                                    items: [],
                                  ),
                                ),
                              );
                            },
                          ),
                          MenuCard(
                            title: "Layanan Kabupaten",
                            subtitle: "Layanan Tingkat Daerah",
                            imagePath:
                                "assets/images/Logo Layanan Kabupaten.png",
                            secondaryColor: secondaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicePage(
                                    title: "Layanan Kabupaten",
                                    subtitle: "Layanan Tingkat Daerah",
                                    imagePath:
                                        "assets/images/Logo Layanan Kabupaten.png",
                                    items: [],
                                  ),
                                ),
                              );
                            },
                          ),
                          MenuCard(
                            title: "Layanan Pendidikan",
                            subtitle: "Layanan Pendidikan",
                            imagePath:
                                "assets/images/Logo Layanan Pendidikan.png",
                            secondaryColor: secondaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicePage(
                                    title: "Layanan Pendidikan",
                                    subtitle: "Layanan Pendidikan",
                                    imagePath:
                                        "assets/images/Logo Layanan Pendidikan.png",
                                    items: [],
                                  ),
                                ),
                              );
                            },
                          ),
                          MenuCard(
                            title: "Layanan KUA",
                            subtitle: "Kantor Urusan Agama",
                            imagePath: "assets/images/Logo KUA.png",
                            secondaryColor: secondaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicePage(
                                    title: "Layanan KUA",
                                    subtitle: "Kantor Urusan Agama",
                                    imagePath: "assets/images/Logo KUA.png",
                                    items: [],
                                  ),
                                ),
                              );
                            },
                          ),
                          MenuCard(
                            title: "Rubrik",
                            subtitle: "Informasi dan Berita",
                            imagePath: "assets/images/Logo Rubrik.png",
                            secondaryColor: secondaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicePage(
                                    title: "Rubrik",
                                    subtitle: "Informasi dan Berita",
                                    imagePath: "assets/images/Logo Rubrik.png",
                                    items: [],
                                  ),
                                ),
                              );
                            },
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
                ref.read(accessibilityMenuProvider.notifier).state = false;
              },
            ),
        ],
      ),
    );
  }
}
