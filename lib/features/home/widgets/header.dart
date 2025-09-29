import 'package:flutter/material.dart';
import 'menu_button.dart'; // 🔹 Import MenuButton

class Header extends StatelessWidget {
  final double topPadding;     // 🔹 padding atas untuk seluruh isi header
  final double textTopMargin;  // 🔹 jarak teks dari logo

  const Header({
    super.key,
    this.topPadding = 45,       // default padding atas
    this.textTopMargin = 10,    // default jarak teks dari logo
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // 🔹 ambil warna dari theme
    final isHighContrast = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 🔹 Background dengan gambar
        Container(
          width: double.infinity,
          height: 200,
          child: Stack(
            children: [
              // Gambar geometric
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/Geometric Pattern.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient fade hanya muncul saat normal
              if (!isHighContrast)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xFF017787), // warna background hijau
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 🔹 Tombol menu
        Positioned(
          top: topPadding,
          right: 20,
          child: const MenuButton(),
        ),

        // 🔹 Logo + teks
        Positioned(
          top: topPadding,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Image.asset(
                "assets/images/logo_gaspul.png",
                height: 120,
              ),
              SizedBox(height: textTopMargin),
              Text(
                "Gerakan Aktif Sistematis Pelayanan Unggul",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
