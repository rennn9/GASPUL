// kemenag_button.dart
import 'package:flutter/material.dart';
import 'package:gaspul/core/routes/no_animation_route.dart';
import 'package:gaspul/features/home/webview_page.dart';

class KemenagButton extends StatelessWidget {
  const KemenagButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          NoAnimationRoute(
            builder: (context) => const WebViewPage(
              url: "https://sulbar.kemenag.go.id/",
              title: "Kemenag SULBAR",
            ),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFF7D914), // kuning stroke
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/images/Logo KEMENAG.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
