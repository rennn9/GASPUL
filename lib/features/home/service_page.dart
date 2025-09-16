import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/theme/theme.dart'; // 🔹 import AppColors
import 'widgets/menu_button.dart';
import 'widgets/accessibility_menu.dart';
import 'home_providers.dart';

class ServicePage extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<String> items;

  const ServicePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(accessibilityMenuProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header pakai warna primary
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColors.primary, // ✅ dari theme.dart
                ),
                child: Stack(
                  children: [
                    // 🔹 Tombol kembali
                    Positioned(
                      top: 40,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primary, // ✅ konsisten
                          ),
                        ),
                      ),
                    ),

                    // 🔹 Tombol Menu
                    const Positioned(
                      top: 40,
                      right: 20,
                      child: MenuButton(),
                    ),

                    // 🔹 Isi header (logo + title + subtitle)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(imagePath, height: 80),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Konten halaman
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(items[index]),
                      ),
                    );
                  },
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
