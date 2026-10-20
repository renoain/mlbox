import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/review.dart';
import '../repositories/review_repository.dart';
import '../repositories/watched_repository.dart';
import '../repositories/watchlist_repository.dart';

final watchlistRepositoryProvider = Provider((ref) => WatchlistRepository());
final watchedRepositoryProvider = Provider((ref) => WatchedRepository());
final reviewRepositoryProvider = Provider((ref) => ReviewRepository());

// Daftar film di watchlist user yang sedang login.
final watchlistProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(watchlistRepositoryProvider);
  return repo.getWatchlist();
});

// Daftar film yang sudah ditonton user yang sedang login.
final watchedProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.watch(watchedRepositoryProvider);
  return repo.getWatched();
});

// Cek satu film ada di watchlist atau tidak.
final isInWatchlistProvider = Provider.family<bool, int>((ref, movieId) {
  final movies = ref.watch(watchlistProvider).valueOrNull ?? const <Movie>[];
  return movies.any((m) => m.id == movieId);
});

// Cek satu film sudah ditandai watched atau tidak.
final isWatchedProvider = Provider.family<bool, int>((ref, movieId) {
  final movies = ref.watch(watchedProvider).valueOrNull ?? const <Movie>[];
  return movies.any((m) => m.id == movieId);
});

// Daftar review milik user yang sedang login.
final myReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getMyReviews();
});
