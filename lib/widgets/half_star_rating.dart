import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bintang interaktif 0.5 step (dipakai di halaman Rate).
///
/// Versi ini diambil dari UI stage 4. `rating_stars.dart` di project hanya
/// menyediakan versi read-only dengan rating `int`, jadi widget interaktif
/// `double` ditempatkan di file terpisah agar tidak mengubah file bersama.
class HalfStarRating extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double size;

  const HalfStarRating({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
  });

  void _set(double dx, {bool toggle = false}) {
    var v = (dx / size * 2).ceil() / 2;
    if (v < 0.5) v = 0.5;
    if (v > 5) v = 5;
    onChanged(toggle && v == value ? 0 : v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) => _set(d.localPosition.dx, toggle: true),
      onHorizontalDragUpdate: (d) => _set(d.localPosition.dx),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => _Star(index: i, value: value, size: size),
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final int index;
  final double value;
  final double size;

  const _Star({required this.index, required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    final filled = value >= index + 1;
    final half = !filled && value >= index + 0.5;
    final isLast = value > index && value <= index + 1;
    return AnimatedScale(
      scale: isLast ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.star_rounded,
              size: size,
              color: filled ? AppColors.green : AppColors.starOff,
            ),
            if (half)
              Icon(Icons.star_half_rounded, size: size, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}
