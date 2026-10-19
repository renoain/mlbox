import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final double size;
  final bool isInteractive;

  const RatingStars({
    super.key,
    this.rating = 0,
    this.size = 20,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive
              ? () {}
              : null, // Logika tap untuk mengubah rating
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: AppTheme.primary, // Hijau
            size: size,
          ),
        );
      }),
    );
  }
}
