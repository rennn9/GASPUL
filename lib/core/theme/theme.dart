import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF017787); // hijau tua
  static const secondary = Color(0xFF05A4AD); // biru toska
  static const subtitle = Color(0xFFF5F5F5); // abu muda
}

class AppTheme {
  // 🔹 Tema Normal (Light)
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.subtitle,

    // ✅ Tambah ukuran base + dynamic scaling
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodySmall: GoogleFonts.poppins(fontSize: 12),
      bodyMedium: GoogleFonts.poppins(fontSize: 14),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
      background: Colors.black,
      onBackground: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),

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

    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white, width: 2),
      ),
      elevation: 0,
    ),
  );
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppColors {
//   // 🔹 Warna default (Normal Theme)
//   static const primary = Color(0xFF017787); // hijau tua
//   static const secondary = Color(0xFF05A4AD); // biru toska
//   static const subtitle = Color(0xFFF5F5F5); // abu muda
// }

// class AppTheme {
//   // 🔹 Tema Normal (Light)
//   static ThemeData lightTheme = ThemeData(
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: AppColors.primary,
//       brightness: Brightness.light,
//     ),
//     scaffoldBackgroundColor: AppColors.subtitle,
//     textTheme: GoogleFonts.poppinsTextTheme(),
//     appBarTheme: const AppBarTheme(
//       elevation: 0,
//     ),
//     cardTheme: CardThemeData(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide.none, // 🔹 default tidak ada border
//       ),
//       elevation: 2,
//     ),
//   );

// // 🔹 Tema High Contrast
// static ThemeData highContrastTheme = ThemeData(
//   colorScheme: const ColorScheme.highContrastDark(
//     primary: Colors.white,
//     onPrimary: Colors.white, // ✅ teks utama putih
//     secondary: Colors.white,
//     onSecondary: Colors.black,
//     surface: Colors.black,
//     onSurface: Colors.white, // ✅ teks di atas surface putih
//     background: Colors.black,
//     onBackground: Colors.white, // ✅ teks di atas background putih
//     error: Colors.red,
//     onError: Colors.white,
//     brightness: Brightness.dark,
//   ),
//   textTheme: GoogleFonts.poppinsTextTheme().apply(
//     bodyColor: Colors.white,    // ✅ semua teks body → putih
//     displayColor: Colors.white, // ✅ teks heading → putih
//   ),
//   scaffoldBackgroundColor: Colors.black,
//   appBarTheme: const AppBarTheme(
//     backgroundColor: Colors.black,
//     foregroundColor: Colors.white, // ✅ teks AppBar putih
//     elevation: 0,
//   ),
//   cardTheme: CardThemeData(
//     color: Colors.black,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//       side: BorderSide(color: Colors.white, width: 2), // border putih
//     ),
//     elevation: 0,
//   ),
// );

// }
