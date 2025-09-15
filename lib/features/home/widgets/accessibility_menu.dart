import 'package:flutter/material.dart';

class AccessibilityMenu extends StatelessWidget {
  final VoidCallback onClose;

  const AccessibilityMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill( // 🔹 agar bisa mendeteksi tap di seluruh layar
      child: Stack(
        children: [
          // 🔹 Background transparan yang bisa ditap untuk close
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withOpacity(0), // transparan penuh
            ),
          ),

          // 🔹 Popup menu di pojok kanan atas
          Positioned(
            top: 40,
            right: 20,
            child: Material(
              color: Colors.transparent,
              elevation: 100, // biarin sesuai selera kamu
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Tombol Close
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 28,
                        color: Color(0xFF05A4AD),
                      ),
                      onPressed: onClose,
                    ),
                  ),

                  // 🔹 Kontainer Menu
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _MenuButton(
                          icon: Icons.brightness_6,
                          label: "Kontras\nTinggi",
                          onTap: null,
                        ),
                        SizedBox(height: 12),
                        _MenuButton(
                          icon: Icons.format_size,
                          label: "Teks\nBesar",
                          onTap: null,
                        ),
                        SizedBox(height: 12),
                        _MenuButton(
                          icon: Icons.volume_up,
                          label: "Baca\nKonten",
                          onTap: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF05A4AD),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
