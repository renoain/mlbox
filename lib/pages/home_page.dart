import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/home_tab_bar.dart';
import '../widgets/letterboks_bottom_nav.dart';
import '../widgets/poster_tile.dart';
// CATATAN: movie_provider.dart sudah tersedia (Riverpod: moviesProvider).
// Halaman ini masih memakai dummy data. Untuk data asli, ubah HomePage
// menjadi ConsumerStatefulWidget lalu pakai ref.watch(moviesProvider):
// import '../providers/movie_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _bg = Color(0xFF191C21);
  static const List<String> _tabs = ['Films', 'Reviews', 'Lists', 'Journal'];

  int _tabIndex = 0;

  // Dummy sementara. posterUrl null -> tampil placeholder.
  static const List<Map<String, dynamic>> _movies = [
    {'id': 1, 'title': 'Digger', 'posterUrl': null, 'rating': 4.5},
    {'id': 2, 'title': 'Other Mommy', 'posterUrl': null, 'rating': 4.8},
    {'id': 3, 'title': 'Resident Evil', 'posterUrl': null, 'rating': 4.2},
    {'id': 4, 'title': 'Primetime', 'posterUrl': null, 'rating': 4.0},
    {'id': 5, 'title': 'The Social Reckoning', 'posterUrl': null, 'rating': 4.1},
    {'id': 6, 'title': 'Verity', 'posterUrl': null, 'rating': 3.9},
    {'id': 7, 'title': 'Spider-Man: Brand New Day', 'posterUrl': null, 'rating': 4.6},
    {'id': 8, 'title': 'Carrie', 'posterUrl': null, 'rating': 3.8},
    {'id': 9, 'title': 'The Love Hypothesis', 'posterUrl': null, 'rating': 4.3},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // Header hitam: judul + tab
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
                      'Letterboks',
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
                      onChanged: (i) => setState(() => _tabIndex = i),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? _buildFilmsTab() : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: LetterboksBottomNav(
        currentIndex: 0,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  /// Aksi bottom nav. Index: 0 Films, 1 Search, 2 Add, 3 Activity, 4 Profile.
  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.push('/search');
        break;
      case 4:
        context.push('/profile');
        break;
      case 0:
        break; // sudah berada di Home
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur ini belum tersedia.')),
        );
    }
  }

  Widget _buildFilmsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final movie = _movies[index];
              return PosterTile(
                title: movie['title'] as String,
                posterUrl: movie['posterUrl'] as String?,
                onTap: () => context.push('/movie/${movie['id']}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
