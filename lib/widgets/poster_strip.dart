import 'package:flutter/material.dart';

import 'poster_image.dart';

/// Baris poster horizontal (untuk kartu list).
class PosterStrip extends StatelessWidget {
  final int count;
  final double height;

  const PosterStrip({super.key, this.count = 8, this.height = 99});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, index) =>
            PosterImage(url: null, width: height * 2 / 3, height: height),
      ),
    );
  }
}
