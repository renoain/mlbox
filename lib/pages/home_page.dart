import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/movie.dart';
import '../models/movie_list.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../providers/movie_provider.dart';

import '../widgets/home_tab_bar.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/poster_image.dart';
import '../widgets/poster_tile.dart';
import '../widgets/rating_stars.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const Color _bg = AppTheme.background;

  static const List<String> _tabs = ['Films', 'Reviews', 'Lists', 'Journal'];

  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Column(
                  children: [
                    const Text(
                      'MLBox',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HomeTabBar(
                      labels: _tabs,
                      selectedIndex: _tabIndex,
                      onChanged: (index) {
                        setState(() => _tabIndex = index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _buildTab(ref)),
        ],
      ),
      bottomNavigationBar: MainBottomNav(currentIndex: isLoggedIn ? 0 : 1),
    );
  }

  Widget _buildTab(WidgetRef ref) {
    switch (_tabIndex) {
      case 0:
        return _buildFilmsTab(ref.watch(moviesProvider));
      case 1:
        return const _ReviewsTab();
      case 2:
        return const _ListsTab();
      default:
        return const _JournalTab();
    }
  }

  Widget _buildFilmsTab(AsyncValue<List<Movie>> moviesAsync) {
    return moviesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00E054)),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat film',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Periksa koneksi dan server API, lalu coba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(moviesProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E054),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (movies) {
        if (movies.isEmpty) {
          return _buildEmptyState();
        }

        return _buildMovieGrid(movies);
      },
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      children: [
        const Text(
          'Popular this week',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];

            return PosterTile(
              title: movie.title,
              posterUrl: movie.posterUrl,
              rating: movie.averageRating ?? 0,
              onTap: () {
                context.push('/movie/${movie.id}');
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.movie_filter_outlined,
              color: Colors.white38,
              size: 52,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada film',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Film yang tersedia akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(moviesProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab "Reviews": review milik user yang sedang login.
class _ReviewsTab extends ConsumerWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    if (!isLoggedIn) {
      return const _SignInPrompt(
        title: 'Masuk untuk melihat review',
        message: 'Review yang kamu tulis akan muncul di sini.',
      );
    }

    final reviewsAsync = ref.watch(myReviewsProvider);

    return reviewsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (error, stackTrace) => _ErrorState(
        message: 'Gagal memuat review',
        detail: error.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(myReviewsProvider),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return const _EmptyState(
            icon: Icons.rate_review_outlined,
            title: 'Belum ada review',
            message: 'Buka sebuah film lalu tulis review pertamamu.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          itemCount: reviews.length,
          itemBuilder: (context, index) => _ReviewCard(review: reviews[index]),
        );
      },
    );
  }
}

/// Tab "Lists": kurasi film milik user yang sedang login.
class _ListsTab extends ConsumerWidget {
  const _ListsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    if (!isLoggedIn) {
      return const _SignInPrompt(
        title: 'Masuk untuk melihat daftar',
        message: 'Kurasi film yang kamu buat akan muncul di sini.',
      );
    }

    final listsAsync = ref.watch(listsProvider);

    return listsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (error, stackTrace) => _ErrorState(
        message: 'Gagal memuat daftar',
        detail: error.toString().replaceFirst('Exception: ', ''),
        onRetry: () => ref.invalidate(listsProvider),
      ),
      data: (lists) {
        if (lists.isEmpty) {
          return const _EmptyState(
            icon: Icons.list_alt_outlined,
            title: 'Belum ada daftar',
            message: 'Kurasi film favoritmu jadi daftar sendiri.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          itemCount: lists.length,
          itemBuilder: (context, index) => _ListCard(list: lists[index]),
        );
      },
    );
  }
}

/// Tab "Journal": belum ada backend artikel, jadi masih placeholder.
class _JournalTab extends StatelessWidget {
  const _JournalTab();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState(
      icon: Icons.auto_stories_outlined,
      title: 'Editorial Journal coming soon',
      message: 'Cerita dan recommendation tentang film akan hadir di sini.',
    );
  }
}

/// Satu kartu review: poster, judul film, rating, dan teksnya.
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

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

/// Satu kartu kurasi: judul, deskripsi, dan jumlah film.
class _ListCard extends StatelessWidget {
  final MovieList list;

  const _ListCard({required this.list});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.list_alt_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${list.itemCount} film'
                  '${list.isPublic ? ' • Publik' : ' • Privat'}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (list.description != null &&
                    list.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    list.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state generik untuk tab yang datanya kosong.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white38, size: 52),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state dengan tombol coba lagi.
class _ErrorState extends StatelessWidget {
  final String message;
  final String detail;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prompt untuk guest: data tab ini hanya milik user yang sudah login.
class _SignInPrompt extends StatelessWidget {
  final String title;
  final String message;

  const _SignInPrompt({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white38, size: 52),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                minimumSize: const Size(160, 50),
              ),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}
