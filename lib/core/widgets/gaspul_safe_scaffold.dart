// lib/core/widgets/gaspul_safe_scaffold.dart
import 'package:flutter/material.dart';

/// 🔹 GasPulSafeScaffold
/// SafeArea hanya aktif untuk perangkat dengan tombol navigasi klasik.
/// Jika menggunakan gesture navigation (usap), padding bawah diabaikan.
class GasPulSafeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const GasPulSafeScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = false,
    this.backgroundColor,
  });

  bool _shouldUseBottomSafeArea(BuildContext context) {
    final view = MediaQuery.of(context);

    final bottomPadding = view.viewPadding.bottom;
    final bottomInset = view.viewInsets.bottom;

    // 📱 Jika gesture navigation aktif, biasanya:
    // - viewPadding.bottom sangat kecil (<20)
    // - viewInsets.bottom == 0 saat keyboard tertutup
    // 📱 Jika tombol klasik:
    // - viewPadding.bottom cukup besar (>= 24)
    if (bottomPadding < 20 && bottomInset == 0) {
      // artinya gesture navigation
      return false;
    }
    return true; // tombol klasik
  }

  @override
  Widget build(BuildContext context) {
    final useBottomSafeArea = _shouldUseBottomSafeArea(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body != null
          ? SafeArea(
              top: false,
              bottom: useBottomSafeArea,
              child: body!,
            )
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar != null
          ? SafeArea(
              top: false,
              bottom: useBottomSafeArea,
              child: bottomNavigationBar!,
            )
          : null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
