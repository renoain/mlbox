import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/movie.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../providers/movie_provider.dart';

import '../widgets/home_tab_bar.dart';
import '../widgets/lists_tab.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/poster_tile.dart';
import '../widgets/reviews_list.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guest: Library ada di index 1, member di index 0.
    final bool isLoggedIn = ref.watch(authProvider).isAuthenticated;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          // Header hitam, tab menyatu dengan AppBar (tanpa kotak).
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'MLBox',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          bottom: const LbTabBar(
            labels: ['Films', 'Reviews', 'Lists', 'Journal'],
          ),
        ),
        // TabBarView supaya tab bisa digeser (swipe).
        body: const TabBarView(
          children: [_FilmsTab(), _ReviewsTab(), _ListsTab(), _JournalTab()],
        ),
        bottomNavigationBar: MainBottomNav(currentIndex: isLoggedIn ? 0 : 1),
      ),
    );
  }
}

/// Tab "Films": grid katalog film.
class _FilmsTab extends ConsumerWidget {
  const _FilmsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildFilmsTab(ref, ref.watch(moviesProvider));
  }

  Widget _buildFilmsTab(WidgetRef ref, AsyncValue<List<Movie>> moviesAsync) {
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
          return _buildEmptyState(ref);
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

  Widget _buildEmptyState(WidgetRef ref) {
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
      data: (reviews) => ReviewsList(
        reviews: reviews,
        emptyTitle: 'Belum ada review',
        emptyMessage: 'Buka sebuah film lalu tulis review pertamamu.',
      ),
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

    return const ListsTab();
  }
}

/// Tab "Journal": belum ada backend artikel, jadi masih placeholder.
class _JournalTab extends StatelessWidget {
  const _JournalTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon buku di dalam lingkaran, biar tidak terlihat kosong.
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surface,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                color: AppTheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Editorial Journal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Editorial Journal will be available soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Cerita, retrospeksi, dan rekomendasi film pilihan',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
