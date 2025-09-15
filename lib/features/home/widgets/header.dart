import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_button.dart'; // 🔹 Import MenuButton

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
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
          top: 40,
          right: 20,
          child: const MenuButton(), // 🔹 Ganti dengan MenuButton
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo_gaspul.png",
                height: 80,
              ),
              const SizedBox(height: 10),
              Text(
                "Gerakan Aktif Sistimatis Pelayanan Unggul",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
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
