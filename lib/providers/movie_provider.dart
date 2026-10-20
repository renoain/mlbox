import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/review.dart';
import '../repositories/home_repository.dart';
import '../repositories/movie_repository.dart';
import '../repositories/review_repository.dart';

final movieRepositoryProvider = Provider((ref) => MovieRepository());
final homeRepositoryProvider = Provider((ref) => HomeRepository());
final reviewRepositoryProvider = Provider((ref) => ReviewRepository());

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

// Review dari semua user untuk sebuah film (endpoint publik).
final movieReviewsProvider = FutureProvider.family<List<Review>, int>((
  ref,
  id,
) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getMovieReviews(id);
});

// Daftar film yang sudah dilike user yang sedang login.
final likedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(movieRepositoryProvider);
  return repo.getLikedMovies();
});

// Beranda terkurasi untuk user login (GET /home).
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getHome();
});
