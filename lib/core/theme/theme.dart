import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF017787);
  static const secondary = Color(0xFF05A4AD);
  static const subtitle = Color(0xFFF5F5F5);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.subtitle,
    textTheme: GoogleFonts.poppinsTextTheme(), // 🔹 semua pakai Poppins
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}