import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/movie.dart';
import '../models/review.dart';
import 'poster_image.dart';
import 'rating_stars.dart';

/// Daftar review: kartu berisi poster film, judul, rating bintang, dan
/// teks reviewnya.
///
/// Dipakai bersama oleh tab "Reviews" di Home dan di Profile supaya
/// tampilannya sama.
class ReviewsList extends StatelessWidget {
  final List<Review> reviews;

  /// Judul saat daftarnya kosong.
  final String emptyTitle;

  /// Keterangan saat daftarnya kosong.
  final String emptyMessage;

  const ReviewsList({
    super.key,
    required this.reviews,
    this.emptyTitle = 'Belum ada review',
    this.emptyMessage = 'Review yang kamu tulis akan muncul di sini.',
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rate_review_outlined,
                color: Colors.white38,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: reviews.length,
      itemBuilder: (context, index) => ReviewCard(review: reviews[index]),
    );
  }
}

/// Satu kartu review.
class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final Movie? movie = review.movie;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movie != null)
            InkWell(
              onTap: () => context.push('/movie/${movie.id}'),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: PosterImage(
                        url: movie.posterUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (review.rating > 0)
                          RatingStars(rating: review.rating, size: 13),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (review.content.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
