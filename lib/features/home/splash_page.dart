import 'package:flutter/material.dart';
import 'package:gaspul/features/home/home_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi fade-in logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigasi ke HomeScreen setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Pattern atas
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/Pattern Down.png',
              fit: BoxFit.fitWidth,
            ),
          ),

          // Pattern bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/Pattern Up.png',
              fit: BoxFit.fitWidth,
            ),
          ),

          // Logo GASPUL di tengah dengan animasi fade
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/images/logo_gaspul.png',
                height: 120, // bisa disesuaikan
              ),
            ),
          ),
        ],
      ),
    );
  }
}
