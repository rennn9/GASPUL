import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_button.dart';
import 'package:gaspul/core/theme/theme.dart';
import 'package:gaspul/features/home/widgets/accessibility_provider.dart';

class Header extends ConsumerWidget {
  final double topPadding;
  final double textTopMargin;

  const Header({
    super.key,
    this.topPadding = 45,
    this.textTopMargin = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighContrast = ref.watch(accessibilityProvider).highContrast;

    Widget backgroundImage = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/images/Geometric Pattern.png"),
          fit: BoxFit.cover,
          colorFilter: isHighContrast
              ? null
              : const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.overlay,
                ),
        ),
      ),
    );

    // 🔸 Jika TIDAK high contrast, bungkus dengan ShaderMask untuk efek fade
    if (!isHighContrast) {
      backgroundImage = ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: backgroundImage,
      );
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 160,
          child: backgroundImage,
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
                height: 80,
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
