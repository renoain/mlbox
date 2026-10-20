import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String title;
  final String posterUrl;
  final double rating;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1D252C),
                      child: const Icon(
                        Icons.movie_rounded,
                        color: Colors.white24,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          if (rating > 0)
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF00E054),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
