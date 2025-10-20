// lib/core/routes/service_navigator.dart
import 'package:flutter/material.dart';
import 'package:gaspul/core/routes/no_animation_route.dart';
import 'package:gaspul/features/home/coming_soon_page.dart';
import 'package:gaspul/features/home/webview_page.dart';
import 'package:gaspul/features/forms/pengaduan_masyarakat_form.dart';
import 'package:gaspul/features/forms/pengaduan_pelayanan_form.dart';
import 'package:gaspul/features/statistics/statistik_pelayanan_page.dart';
import 'package:gaspul/features/home/widgets/queue_bottom_sheet.dart';
import 'package:gaspul/features/home/service_page.dart';

/// 🔹 Fungsi helper untuk navigasi berdasarkan item menu
void navigateFromServiceItem(BuildContext context, Map<String, String> item) {
  final title = item["title"] ?? "Layanan";
  final link = item["link"];
  final nestedPage = item["nestedPage"];

  // 1️⃣ Antrian
  if (title == "Ambil Antrian") {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const QueueBottomSheet(),
    );
    return;
  }

  // 2️⃣ Nested Page → buka ServicePage baru sesuai key
  if (nestedPage != null && nestedPage.isNotEmpty) {
    Navigator.of(context).push(
      NoAnimationRoute(
        builder: (context) => ServicePage(
          layananKey: nestedPage,
          title: title,
        ),
      ),
    );
    return;
  }

  // 3️⃣ Link → buka WebView
  if (link != null && link.isNotEmpty) {
    Navigator.of(context).push(
      NoAnimationRoute(
        builder: (context) => WebViewPage(
          url: link,
          title: title,
        ),
      ),
    );
    return;
  }

  if (title == "Statistik Pelayanan") {
    Navigator.of(context).push(
      NoAnimationRoute(
        builder: (context) => const StatistikPelayananPage(),
      ),
    );
    return;
  }

  // 5️⃣ Fallback → Coming Soon
  Navigator.of(context).push(
    NoAnimationRoute(
      builder: (context) => ComingSoonPage(title: title),
    ),
  );
}
