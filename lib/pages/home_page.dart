import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import '../repositories/home_repository.dart';
import '../widgets/home_tab_bar.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/poster_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const Color _bg = Color(0xFF191C21);

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
          Expanded(
            child: _tabIndex == 0
                ? (isLoggedIn
                      ? _buildHomeTab(ref.watch(homeDataProvider))
                      : _buildFilmsTab(ref.watch(moviesProvider)))
                : _buildComingSoonTab(_tabs[_tabIndex]),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(currentIndex: isLoggedIn ? 0 : 1),
    );
  }

  Widget _buildHomeTab(AsyncValue<HomeData> homeAsync) {
    return homeAsync.when(
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
                'Gagal memuat beranda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(homeDataProvider),
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
      data: (home) {
        final sections = <(String, List<Movie>)>[
          ('Featured', home.featured),
          ('Latest', home.latest),
          ('Top Rated', home.topRated),
          ('Most Watched', home.mostWatched),
          ('Most Watchlisted', home.mostWatchlisted),
          ('Explore', home.explore),
        ].where((s) => s.$2.isNotEmpty).toList();

        if (sections.isEmpty) {
          return _buildEmptyState();
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
          children: [
            for (final (title, movies) in sections) ...[
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionRow(movies),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionRow(List<Movie> movies) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return SizedBox(
            width: 120,
            child: PosterTile(
              title: movie.title,
              posterUrl: movie.posterUrl,
              onTap: () => context.push('/movie/${movie.id}'),
            ),
          );
        },
      ),
    );
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

  Widget _buildComingSoonTab(String tabName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_rounded,
              color: Colors.white38,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '$tabName segera hadir',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bagian $tabName belum tersedia.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
