import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/movie_card.dart';
// CATATAN: movie_provider.dart sudah tersedia (Riverpod: moviesProvider).
// Halaman ini masih memakai dummy data. Untuk data asli, ubah HomePage
// menjadi ConsumerWidget lalu pakai ref.watch(moviesProvider):
// import '../providers/movie_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sementara pakai dummy list karena data dari movieProvider belum dipakai
    final List<Map<String, dynamic>> dummyMovies = [
      {
        'id': 1,
        'title': 'Avatar 4',
        'posterUrl': 'https://via.placeholder.com/150',
        'rating': 4.5,
      },
      {
        'id': 2,
        'title': 'Coco 2',
        'posterUrl': 'https://via.placeholder.com/150',
        'rating': 4.8,
      },
      {
        'id': 3,
        'title': 'A24 Film',
        'posterUrl': 'https://via.placeholder.com/150',
        'rating': 4.2,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF14181C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14181C),
        elevation: 0,
        title: const Text(
          'Popular Movies',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TRENDING THIS WEEK',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dummyMovies.length,
                itemBuilder: (context, index) {
                  final item = dummyMovies[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D252C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        item['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ALL MOVIES',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Color(0xFF00E054)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.52,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
              ),
              itemCount: dummyMovies.length,
              itemBuilder: (context, index) {
                final movie = dummyMovies[index];
                return MovieCard(
                  title: movie['title'],
                  posterUrl: movie['posterUrl'],
                  rating: movie['rating'],
                  onTap: () => context.push('/movie/${movie['id']}'),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
