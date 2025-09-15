import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatelessWidget {
  final VoidCallback onMenuPressed; // 🔹 Tambahkan callback

  const Header({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    const secondaryColor = Color(0xFF05A4AD);

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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onMenuPressed, // 🔹 pakai callback
              icon: const Icon(
                Icons.menu,
                color: secondaryColor,
                size: 28,
              ),
            ),
          ),
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