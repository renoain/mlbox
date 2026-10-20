import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/movie_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> _filter(List<Movie> movies) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return movies;
    return movies.where((m) => m.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;
    final moviesAsync = ref.watch(moviesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF14181C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF182128),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search movies, actors, lists...',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: Icon(Icons.search, color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'BROWSE CATALOG',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: moviesAsync.when(
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
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(moviesProvider),
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
                  data: (movies) => _buildResults(_filter(movies)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNav(currentIndex: isLoggedIn ? 1 : 2),
    );
  }

  Widget _buildResults(List<Movie> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                color: Colors.white38,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _query.trim().isEmpty
                    ? 'Belum ada film'
                    : 'Tidak ada hasil untuk "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          title: movie.title,
          posterUrl: movie.posterUrl ?? '',
          rating: 0,
          onTap: () => context.push('/movie/${movie.id}'),
        );
      },
    );
  }
}
