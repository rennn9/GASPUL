import 'package:flutter/material.dart';
import 'package:gaspul/core/widgets/accessible_tap.dart';

/// Komponen utama untuk menampilkan kumpulan MenuCard responsif
class MenuCardGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;

  const MenuCardGrid({
    super.key,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isDesktop = size.width >= 1000;

    // Jumlah kolom sesuai ukuran layar
    int crossAxisCount = 2;
    if (isTablet) crossAxisCount = 3;
    if (isDesktop) crossAxisCount = 4;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 1.2 : 0.9,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return MenuCard(
          title: item['title'],
          subtitle: item['subtitle'],
          imagePath: item['imagePath'],
          onTap: item['onTap'],
        );
      },
    );
  }
}

/// Widget individual card menu, mendukung orientasi dan layar besar
class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback? onTap;
  final double height;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.onTap,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isTablet = size.shortestSide >= 600;

    // Responsif tinggi & font
    final double responsiveHeight = isTablet
        ? height * 1.2
        : isLandscape
            ? height * 0.9
            : height;

    final double imageHeight = isTablet
        ? 100
        : isLandscape
            ? 80
            : 70;

    final double titleFontSize = isTablet
        ? 20
        : isLandscape
            ? 18
            : 16;

    final double subtitleFontSize = isTablet
        ? 16
        : isLandscape
            ? 14
            : 13;

    // Jika landscape dan lebar, gunakan row layout
    final bool useRowLayout = isLandscape && size.width > 600;

    return AccessibleTap(
      label: "$title, $subtitle",
      onTap: onTap,
      child: SizedBox(
        height: responsiveHeight,
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: colors.primary.withOpacity(0.2),
            highlightColor: colors.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: useRowLayout
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Image.asset(imagePath, height: imageHeight),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: colors.secondary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface.withOpacity(0.8),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(imagePath, height: imageHeight),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w900,
                            color: colors.secondary,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface.withOpacity(0.8),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
