import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/data/service_data.dart'; // 🔹 data layanan
import 'widgets/menu_button.dart';
import 'widgets/accessibility_menu.dart';
import 'home_providers.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/core/widgets/accessible_tap.dart'; // 🔹 TTS wrapper
import 'webview_page.dart';
import 'package:gaspul/core/routes/no_animation_route.dart'; // 🔹 no-animation route

// 🔹 Import form pages
import 'package:gaspul/features/forms/pengaduan_masyarakat_form.dart';
import 'package:gaspul/features/forms/pengaduan_pelayanan_form.dart';

class ServicePage extends ConsumerWidget {
  final String layananKey; // 🔹 kunci data layanan (publik, internal, dll)
  final String title; // 🔹 judul di header

  const ServicePage({super.key, required this.layananKey, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMenuOpen = ref.watch(accessibilityMenuProvider);

    // 🔹 Ambil data layanan berdasarkan key
    final layananConfig =
        layananData[layananKey] as Map<String, dynamic>? ?? {};
    final List<Map<String, String>> layananList =
        (layananConfig["items"] as List?)?.cast<Map<String, String>>() ?? [];
    final String layout = layananConfig["layout"] as String? ?? "grid";

    final theme = Theme.of(context); // 🔹 ambil theme aktif

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Header
              Container(
                height: 200,
                decoration: BoxDecoration(color: theme.primaryColor),
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
                          child: Icon(
                            Icons.arrow_back,
                            color: theme.brightness == Brightness.dark
                                ? Colors.black
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    // 🔹 Tombol Menu
                    const Positioned(top: 40, right: 20, child: MenuButton()),

                    // 🔹 Isi header
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

              // 🔹 Konten layanan
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
                              onTap: () {
                                final title = item["title"];
                                if (item["link"] != null) {
                                  Navigator.of(context).push(
                                    NoAnimationRoute(
                                      builder: (context) => WebViewPage(
                                        url: item["link"]!,
                                        title: title!,
                                      ),
                                    ),
                                  );
                                } else if (title == "Pengaduan Masyarakat") {
                                  Navigator.of(context).push(
                                    NoAnimationRoute(
                                      builder: (context) =>
                                          const PengaduanMasyarakatForm(),
                                    ),
                                  );
                                } else if (title == "Pengaduan Pelayanan") {
                                  Navigator.of(context).push(
                                    NoAnimationRoute(
                                      builder: (context) =>
                                          const PengaduanPelayananForm(),
                                    ),
                                  );
                                }
                              },
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
                              onTap: () {
                                final title = item["title"];
                                if (item["link"] != null) {
                                  Navigator.of(context).push(
                                    NoAnimationRoute(
                                      builder: (context) => WebViewPage(
                                        url: item["link"]!,
                                        title: title!,
                                      ),
                                    ),
                                  );
                                } else if (title == "Pengaduan Masyarakat") {
                                  Navigator.of(context).push(
                                    NoAnimationRoute(
                                      builder: (context) =>
                                          const PengaduanMasyarakatForm(),
                                    ),
                                  );
                                } else if (title == "Pengaduan Pelayanan") {
                                  Navigator.of(context).push(
                                    NoAnimationRoute(
                                      builder: (context) =>
                                          const PengaduanPelayananForm(),
                                    ),
                                  );
                                }
                              },
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
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
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



// Kode Sebelum Ditambahkan WebView
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gaspul/core/data/service_data.dart'; // 🔹 data layanan
// import 'widgets/menu_button.dart';
// import 'widgets/accessibility_menu.dart';
// import 'home_providers.dart';
// import 'package:gaspul/core/theme/theme.dart';
// import 'package:gaspul/core/widgets/accessible_tap.dart'; // 🔹 TTS wrapper

// class ServicePage extends ConsumerWidget {
//   final String layananKey; // 🔹 kunci data layanan (publik, internal, dll)
//   final String title; // 🔹 judul di header

//   const ServicePage({super.key, required this.layananKey, required this.title});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isMenuOpen = ref.watch(accessibilityMenuProvider);

//     // 🔹 Ambil data layanan berdasarkan key
//     final layananConfig =
//         layananData[layananKey] as Map<String, dynamic>? ?? {};
//     final List<Map<String, String>> layananList =
//         (layananConfig["items"] as List?)?.cast<Map<String, String>>() ?? [];
//     final String layout = layananConfig["layout"] as String? ?? "grid";

//     final theme = Theme.of(context); // 🔹 ambil theme aktif

//     return Scaffold(
//       backgroundColor: theme.primaryColor, // 🔹 ikut kontras tinggi
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               // 🔹 Header
//               Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: theme.primaryColor, // 🔹 ikut kontras tinggi
//                 ),
//                 child: Stack(
//                   children: [
//                     // 🔹 Tombol kembali
//                     Positioned(
//                       top: 40,
//                       left: 20,
//                       child: GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           width: 40,
//                           height: 40,
//                           decoration: const BoxDecoration(
//                             color: Colors.white, // ✅ selalu putih
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.arrow_back,
//                             color: theme.brightness == Brightness.dark
//                                 ? Colors
//                                       .black // ✅ High Contrast → hitam
//                                 : AppColors.primary, // ✅ Normal → hijau tua
//                           ),
//                         ),
//                       ),
//                     ),

//                     // 🔹 Tombol Menu
//                     const Positioned(top: 40, right: 20, child: MenuButton()),

//                     // 🔹 Isi header
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 20),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (layananConfig["image"] != null)
//                               Image.asset(
//                                 layananConfig["image"] as String,
//                                 height: 80,
//                               ),
//                             const SizedBox(height: 4),
//                             Text(
//                               title,
//                               style: theme.textTheme.titleLarge?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: theme
//                                     .colorScheme
//                                     .onPrimary, // 🔹 teks kontras
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // 🔹 Konten layanan
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.all(0),
//                   padding: const EdgeInsets.only(
//                     left: 20,
//                     right: 20,
//                     bottom: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     color:
//                         theme.scaffoldBackgroundColor, // 🔹 ikut kontras tinggi
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(32),
//                       topRight: Radius.circular(32),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),

//                   // 🔹 child tetap pakai layout sesuai service_data
//                   child: layout == "list"
//                       ? ListView.builder(
//                           itemCount: layananList.length,
//                           itemBuilder: (context, index) {
//                             final item = layananList[index];
//                             return AccessibleTap(
//                               label: item["title"] ?? "",
//                               child: Card(
//                                 margin: const EdgeInsets.symmetric(vertical: 8),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(18),
//                                   child: ListTile(
//                                     leading: Image.asset(
//                                       item["icon"]!,
//                                       height: 45,
//                                       width: 45,
//                                     ),
//                                     title: Text(item["title"] ?? ""),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       : GridView.builder(
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 mainAxisSpacing: 16,
//                                 crossAxisSpacing: 16,
//                                 childAspectRatio: 1,
//                               ),
//                           itemCount: layananList.length,
//                           itemBuilder: (context, index) {
//                             final item = layananList[index];
//                             return AccessibleTap(
//                               label: item["title"] ?? "",
//                               child: Card(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Image.asset(
//                                       item["icon"]!,
//                                       height: 75,
//                                       width: 75,
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Text(
//                                       item["title"] ?? "",
//                                       textAlign: TextAlign.center,
//                                       style: theme.textTheme.bodySmall?.copyWith(
//                                             fontWeight: FontWeight.w900, // font super tebal
//                                           ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ),
//             ],
//           ),

//           // 🔹 Popup Accessibility Menu
//           if (isMenuOpen)
//             AccessibilityMenu(
//               onClose: () {
//                 ref.read(accessibilityMenuProvider.notifier).state = false;
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }
