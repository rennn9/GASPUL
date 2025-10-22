import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/data/service_data.dart';
import 'widgets/menu_button.dart';
import 'widgets/accessibility_menu.dart';
import 'home_providers.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/widgets/accessible_tap.dart';
import 'package:gaspul/core/routes/service_navigator.dart';
import 'package:gaspul/core/widgets/gaspul_safe_scaffold.dart'; // ✅ pakai safe scaffold

class ServicePage extends ConsumerWidget {
  final String layananKey;
  final String title;

  const ServicePage({super.key, required this.layananKey, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(accessibilityMenuProvider);

    final layananConfig = layananData[layananKey] as Map<String, dynamic>? ?? {};
    final List<Map<String, String>> layananList =
        (layananConfig["items"] as List?)?.cast<Map<String, String>>() ?? [];
    final String layout = layananConfig["layout"] as String? ?? "grid";

    final theme = Theme.of(context);

    return GasPulSafeScaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.serviceHeaderBgHighContrast
          : AppColors.serviceHeaderBg,
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.serviceHeaderBgHighContrast
                      : AppColors.serviceHeaderBg,
                ),
                child: Stack(
                  children: [
                    // 🔙 Tombol kembali
                    Positioned(
                      top: 40,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.serviceBackButtonBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: theme.brightness == Brightness.dark
                                ? AppColors.serviceBackButtonIconHighContrast
                                : AppColors.serviceBackButtonIconNormal,
                          ),
                        ),
                      ),
                    ),

                    // 🔸 Tombol Menu
                    const Positioned(top: 40, right: 20, child: MenuButton()),

                    // 📝 Isi header
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (layananConfig["image"] != null)
                              Image.asset(
                                layananConfig["image"] as String,
                                height: 80,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 📄 Konten
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.serviceCardShadow,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: layout == "list"
                      ? ListView.builder(
                          itemCount: layananList.length,
                          itemBuilder: (context, index) {
                            final item = layananList[index];
                            return AccessibleTap(
                              label: item["title"] ?? "",
                              onTap: () => navigateFromServiceItem(context, item),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: ListTile(
                                    leading: Image.asset(
                                      item["icon"]!,
                                      height: 45,
                                      width: 45,
                                    ),
                                    title: Text(item["title"] ?? ""),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1,
                              ),
                          itemCount: layananList.length,
                          itemBuilder: (context, index) {
                            final item = layananList[index];
                            return AccessibleTap(
                              label: item["title"] ?? "",
                              onTap: () => navigateFromServiceItem(context, item),
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      item["icon"]!,
                                      height: 75,
                                      width: 75,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item["title"] ?? "",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),

          // ♿ Accessibility Menu
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
