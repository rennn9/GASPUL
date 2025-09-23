import 'package:flutter/material.dart';
import 'splash_second.dart'; // pastikan path ini sesuai

class SplashFirst extends StatefulWidget {
  const SplashFirst({super.key});

  @override
  State<SplashFirst> createState() => _SplashFirstState();
}

class _SplashFirstState extends State<SplashFirst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi fade-in logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Navigasi ke SplashSecond setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashSecond()),
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
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // vertikal center
            crossAxisAlignment: CrossAxisAlignment.center, // horizontal center
            children: [
              Image.asset(
                'assets/images/Logo KEMENAG.png',
                height: 110, // sesuaikan ukuran
              ),
              const SizedBox(height: 10), // gap antar elemen
              Text(
                'Kantor Wilayah Kementrian Agama\nProvinsi Sulawesi Barat',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black87, // tetap bisa diatur warna
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
