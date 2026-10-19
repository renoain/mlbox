import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../providers/movie_provider.dart';
import '../widgets/rating_stars.dart'; // Panggil widget rating

class MovieDetailPage extends ConsumerWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: movieAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (movie) {
          return CustomScrollView(
            slivers: [
              // 1. BACKDROP & POSTER KECIL
              SliverAppBar(
                expandedHeight: 350.0,
                pinned: true,
                backgroundColor: AppTheme.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gambar Backdrop (Pakai Poster dulu)
                      movie.posterUrl != null
                          ? Image.network(movie.posterUrl!, fit: BoxFit.cover)
                          : Container(color: AppTheme.surface),
                      // Gradient gelap di bawah
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppTheme.background, Colors.transparent],
                            stops: [0.0, 0.6],
                          ),
                        ),
                      ),
                      // Judul, Tahun, & Poster Kecil
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${movie.releaseDate} • ${movie.runtime} mins',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Poster Kecil di Kanan (menindih backdrop)
                            Container(
                              width: 70,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: movie.posterUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(movie.posterUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: AppTheme.surface,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. KONTEN DETAIL (Sinopsis, Rating, dll)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating Stars (Tugas Teman B)
                      Row(
                        children: [
                          const Text(
                            'RATINGS',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const RatingStars(
                            rating: 4,
                          ), // Dummy rating 4 bintang
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol Aksi (Watchlist & Watched) - Warna Hijau & Abu
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Logika tambah ke Watchlist
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('WATCHLIST'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary, // HIJAU
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Logika tandai Watched
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('WATCHED'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF3B444F,
                                ), // ABU-ABU
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sinopsis
                      Text(
                        movie.overview ?? 'Tidak ada sinopsis.',
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Section Cast
                      const Text(
                        'CAST',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCastRow('Christian Bale', 'Patrick Bateman'),
                      _buildCastRow('Justin Theroux', 'Timothy Bryce'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget Bantuan untuk Baris Cast
  Widget _buildCastRow(String name, String character) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                character,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
