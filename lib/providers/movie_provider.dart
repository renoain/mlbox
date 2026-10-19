import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/review.dart';
import '../repositories/movie_repository.dart';

final movieRepositoryProvider = Provider((ref) => MovieRepository());

// Provider untuk mengambil semua daftar film (Home)
final moviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getMovies();
});

// Provider untuk mengambil detail 1 film berdasarkan ID
final movieDetailProvider = FutureProvider.family<Movie, int>((ref, id) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getMovieDetail(id);
});

// Provider untuk mengambil review film
final movieReviewsProvider = FutureProvider.family<List<Review>, int>((
  ref,
  movieId,
) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getMovieReviews(movieId);
});
