import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class TotalPelayananCard extends StatelessWidget {
  final int total;

  const TotalPelayananCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Total Pelayanan Berhasil",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedFlipCounter(
              value: total.toDouble(),
              textStyle: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: Colors.green,
              ),
              thousandSeparator: ',',
            ),
          ],
        ),
      ),
    );
  }
}
