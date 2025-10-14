// core/theme/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0388A9);
  static const secondary = Color(0xFFFB7C02);
  static const subtitle = Color(0xFFF5F5F5); // abu muda

  // 🔹 Warna tombol Kemenag
  static const kemenagButtonNormal = Colors.white;
  static const kemenagButtonHighContrast = Colors.black;
  static const kemenagButtonBorder = Color(0xFFF7D914);

  // 🔹 Warna MenuButton
  static const menuButtonNormalBg = Colors.white;
  static const menuButtonHighContrastIcon = Colors.black;
  static const menuButtonNormalIcon = secondary;

  // 🔹 Warna ComingSoonPage
  static const comingSoonAppBarFg = Colors.white;
  static const comingSoonButtonText = Colors.white;
  static const comingSoonButtonBorder = Colors.white;

  // 🔹 Warna HomeScreen
  static const homeBackgroundNormal = primary;
  static const homeBackgroundHighContrast = Colors.black;
  static const homeBottomBarNormal = Colors.white;
  static const homeBottomBarHighContrast = Color(0xFF424242); // abu gelap
  static const homeBottomBarShadow = Colors.black26;

  // ServicePage header — normal & high contrast
  static const serviceHeaderBg = primary; // normal
  static const serviceHeaderBgHighContrast = Colors.black; // high contrast

  static const serviceBackButtonBg = Colors.white;
  static const serviceBackButtonIconNormal = primary;
  static const serviceBackButtonIconHighContrast = Colors.black;
  static const serviceCardShadow = Colors.black26;
}

class AppTheme {
  // 🔹 Tema Light
static ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    secondary: AppColors.secondary, // ✅ Tambahkan ini
  ),
  scaffoldBackgroundColor: AppColors.subtitle,
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    bodySmall: GoogleFonts.poppins(fontSize: 12),
    bodyMedium: GoogleFonts.poppins(fontSize: 14),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(elevation: 0),
  cardTheme: const CardThemeData(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide.none,
    ),
    elevation: 2,
  ),
);


  // 🔹 Tema High Contrast
  static ThemeData highContrastTheme = ThemeData(
    colorScheme: const ColorScheme.highContrastDark(
      primary: Colors.white,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ).copyWith(
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Colors.white, width: 2),
      ),
      elevation: 0,
    ),
  );
}
