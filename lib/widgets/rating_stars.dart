import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final double size;
  final bool isInteractive;
  final Function(int)? onRatingChanged;

  const RatingStars({
    super.key,
    this.rating = 0,
    this.size = 20,
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: AppTheme.primary,
            size: size,
          ),
        );
      }),
    );
  }
}
