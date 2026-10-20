import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/movie_list.dart';
import '../models/review.dart';
import '../models/watched_entry.dart';
import '../repositories/diary_repository.dart';
import '../repositories/list_repository.dart';
import '../repositories/watched_repository.dart';
import '../repositories/watchlist_repository.dart';
import 'movie_provider.dart';

final watchlistRepositoryProvider = Provider((ref) => WatchlistRepository());
final watchedRepositoryProvider = Provider((ref) => WatchedRepository());
final diaryRepositoryProvider = Provider((ref) => DiaryRepository());
final listRepositoryProvider = Provider((ref) => ListRepository());

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

// Daftar film yang sudah ditonton beserta tanggalnya.
final watchedEntriesProvider = FutureProvider<List<WatchedEntry>>((ref) async {
  final repo = ref.watch(watchedRepositoryProvider);
  return repo.getWatchedEntries();
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

// Log/diary user yang sedang login, dikelompokkan per tanggal.
final diaryProvider = FutureProvider<List<DiaryDay>>((ref) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.getDiary();
});

// Kurasi film milik user yang sedang login.
final listsProvider = FutureProvider<List<MovieList>>((ref) async {
  final repo = ref.watch(listRepositoryProvider);
  return repo.getMyLists();
});
