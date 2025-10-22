// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/features/home/splash_first.dart';
import 'package:gaspul/features/home/widgets/accessibility_provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- tambahkan

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi locale Indonesia untuk DateFormat
  await initializeDateFormatting('id', null);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return MaterialApp(
      title: 'GASPUL',
      debugShowCheckedModeBanner: false,

      // 🔹 Pilih tema berdasarkan highContrast
      theme: accessibility.highContrast
          ? AppTheme.highContrastTheme
          : AppTheme.lightTheme,

      // 🔹 Override MediaQuery untuk scaling teks
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaleFactor: accessibility.largeText ? 0.8 : 0.7,
          ),
          child: child!,
        );
      },

      home: const SplashFirst(),
    );
  }
}




// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gaspul/core/theme/theme.dart';
// import 'package:gaspul/features/home/home_screen.dart';
// import 'package:gaspul/features/home/splash_first.dart'; // ✅ splash page pertama
// import 'package:gaspul/features/home/widgets/accessibility_provider.dart';

// void main() {
//   runApp(
//     const ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final accessibility = ref.watch(accessibilityProvider);

//     return MaterialApp(
//       title: 'GASPUL',
//       debugShowCheckedModeBanner: false,
//       theme: accessibility.highContrast
//           ? AppTheme.highContrastTheme
//           : AppTheme.lightTheme,
//       home: const SplashFirst(), // ✅ tampilkan splash page pertama
//     );
//   }
// }
