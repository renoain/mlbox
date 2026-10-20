import 'package:flutter/material.dart';

import 'poster_image.dart';

/// Kartu poster untuk grid Home: poster full, border tipis,
/// judul di bawah dengan gradient gelap (sesuai desain Katalog Film).
class PosterTile extends StatelessWidget {
  final String title;
  final String? posterUrl;
  final double rating;
  final VoidCallback? onTap;

  const PosterTile({
    super.key,
    required this.title,
    this.posterUrl,
    this.rating = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x66FFFFFF), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPoster(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC000000)],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),
              if (rating > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: _RatingBadge(rating: rating),
                ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 10,
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return PosterImage(url: posterUrl, fit: BoxFit.cover);
  }
}

/// Lencana rating bintang di pojok poster.
class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFF00E054), size: 11),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
