import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import 'avatar_placeholder.dart';
import 'login_reminder.dart';
import 'poster_image.dart';
import 'rating_stars.dart';

const BoxDecoration _rowDivider = BoxDecoration(
  border: Border(bottom: BorderSide(color: AppColors.divider)),
);

/// Hasil search tab Films / dipakai juga di Add a film.
class FilmResultTile extends StatelessWidget {
  final FilmItem film;
  final VoidCallback? onTap;

  const FilmResultTile({super.key, required this.film, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: _rowDivider,
        child: Row(
          children: [
            PosterImage(width: 52, height: 78, url: film.posterUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: film.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' ${film.year}, directed by ',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: film.director,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hasil search tab Reviews. Tap hati = butuh login.
class ReviewResultCard extends StatefulWidget {
  final ReviewItem review;
  const ReviewResultCard({super.key, required this.review});

  @override
  State<ReviewResultCard> createState() => _ReviewResultCardState();
}

class _ReviewResultCardState extends State<ReviewResultCard> {
  late bool _liked = widget.review.liked;

  Future<void> _toggleLike() async {
    final ok = await requireLogin(context, action: 'like this review');
    if (ok && mounted) setState(() => _liked = !_liked);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: _rowDivider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: r.film.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' ${r.film.year}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                r.user,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const AvatarPlaceholder(
                width: 28,
                height: 28,
                radius: 14,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              RatingStars(rating: r.rating.round()),
              const SizedBox(width: 6),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleLike,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedScale(
                    scale: _liked ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      Icons.favorite,
                      size: 15,
                      color: _liked ? AppColors.orange : AppColors.starOff,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PosterImage(width: 56, height: 84, url: r.film.posterUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  r.text,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hasil search tab Lists: judul, owner, strip poster.
class ListResultCard extends StatelessWidget {
  final ListItem list;
  final VoidCallback? onTap;

  const ListResultCard({super.key, required this.list, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: _rowDivider,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    list.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  list.owner,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(width: 8),
                const AvatarPlaceholder(
                  width: 28,
                  height: 28,
                  radius: 14,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                6,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 5 ? 0 : 3),
                    child: const AspectRatio(
                      aspectRatio: 2 / 3,
                      child: PosterImage(url: null),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${list.filmCount} films',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hasil search tab Cast, Crew or Studios.
class PersonResultTile extends StatelessWidget {
  final PersonItem person;
  const PersonResultTile({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _rowDivider,
      child: Row(
        children: [
          const AvatarPlaceholder(
            width: 52,
            height: 66,
            radius: 4,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  person.description,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
