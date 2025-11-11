import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/data/service_data.dart';
import 'widgets/menu_button.dart';
import 'widgets/accessibility_menu.dart';
import 'home_providers.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/widgets/accessible_tap.dart';
import 'package:gaspul/core/routes/service_navigator.dart';
import 'package:gaspul/core/widgets/gaspul_safe_scaffold.dart';

class ServicePage extends ConsumerWidget {
  final String layananKey;
  final String title;

  const ServicePage({super.key, required this.layananKey, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(accessibilityMenuProvider);
    final theme = Theme.of(context);

    final layananConfig = layananData[layananKey] as Map<String, dynamic>? ?? {};
    final List<Map<String, String>> layananList =
        (layananConfig["items"] as List?)?.cast<Map<String, String>>() ?? [];
    final String layout = layananConfig["layout"] as String? ?? "grid";

    return GasPulSafeScaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.serviceHeaderBgHighContrast
          : AppColors.serviceHeaderBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final bool isTablet = screenWidth >= 600 && screenWidth < 900;
          final bool isDesktop = screenWidth >= 900;

          // 🔹 Responsif: padding dan ukuran header menyesuaikan
          final double headerHeight = isDesktop
              ? 260
              : isTablet
                  ? 220
                  : 200;

          final double gridSpacing = isDesktop ? 24 : (isTablet ? 18 : 14);
          final int gridCount = isDesktop
              ? 5
              : isTablet
                  ? 3
                  : 2;

          return Stack(
            children: [
              Column(
                children: [
                  // 🔹 Header responsif
                  Container(
                    height: headerHeight,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.serviceHeaderBgHighContrast
                          : AppColors.serviceHeaderBg,
                    ),
                    child: Stack(
                      children: [
                        // 🔙 Tombol kembali
                        Positioned(
                          top: isDesktop ? 50 : 40,
                          left: isDesktop ? 40 : 20,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: const BoxDecoration(
                                color: AppColors.serviceBackButtonBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: isDesktop ? 28 : 24,
                                color: theme.brightness == Brightness.dark
                                    ? AppColors.serviceBackButtonIconHighContrast
                                    : AppColors.serviceBackButtonIconNormal,
                              ),
                            ),
                          ),
                        ),

                        // 🔸 Tombol Menu
                        Positioned(
                          top: isDesktop ? 50 : 40,
                          right: isDesktop ? 40 : 20,
                          child: const MenuButton(),
                        ),

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
                                    height: isDesktop
                                        ? 100
                                        : isTablet
                                            ? 90
                                            : 80,
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop
                                        ? 28
                                        : isTablet
                                            ? 24
                                            : 20,
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

                  // 📄 Konten utama
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop
                            ? 60
                            : isTablet
                                ? 40
                                : 20,
                        vertical: 20,
                      ),
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
                                  onTap: () =>
                                      navigateFromServiceItem(context, item),
                                  child: Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: ListTile(
                                        leading: Image.asset(
                                          item["icon"]!,
                                          height: 45,
                                          width: 45,
                                        ),
                                        title: Text(
                                          item["title"] ?? "",
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridCount,
                                mainAxisSpacing: gridSpacing,
                                crossAxisSpacing: gridSpacing,
                                childAspectRatio: isDesktop
                                    ? 1.1
                                    : isTablet
                                        ? 1
                                        : 0.9,
                              ),
                              itemCount: layananList.length,
                              itemBuilder: (context, index) {
                                final item = layananList[index];
                                return AccessibleTap(
                                  label: item["title"] ?? "",
                                  onTap: () =>
                                      navigateFromServiceItem(context, item),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            item["icon"]!,
                                            height: isDesktop
                                                ? 90
                                                : isTablet
                                                    ? 80
                                                    : 70,
                                            width: isDesktop
                                                ? 90
                                                : isTablet
                                                    ? 80
                                                    : 70,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            item["title"] ?? "",
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              fontSize: isDesktop
                                                  ? 18
                                                  : isTablet
                                                      ? 16
                                                      : 14,
                                            ),
                                          ),
                                        ],
                                      ),
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
          );
        },
      ),
    );
  }
}
