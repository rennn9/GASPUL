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

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Geometric Pattern.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: topPadding,
          right: 20,
          child: const MenuButton(), // 🔹 tombol menu mengikuti top padding
        ),
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
                "Gerakan Aktif Sistimatis Pelayanan Unggul",
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
