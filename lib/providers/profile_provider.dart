import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/profile_stats.dart';
import '../providers/auth_provider.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());
final favoriteRepositoryProvider = Provider((ref) => FavoriteRepository());

/// Statistik profil user yang sedang login.
///
/// Endpoint-nya butuh token, jadi untuk guest tidak dipanggil sama sekali
/// (nilai kosong). Provider ini tetap bergantung pada `authProvider`, jadi
/// otomatis diambil ulang begitu user login.
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  if (!ref.watch(authProvider).isAuthenticated) {
    return const ProfileStats();
  }

  final repo = ref.watch(profileRepositoryProvider);
  return repo.getStats();
});

/// Film favorit user yang sedang login (4 slot di halaman profil/settings).
final favoritesProvider = FutureProvider<List<Movie>>((ref) async {
  if (!ref.watch(authProvider).isAuthenticated) {
    return const [];
  }

  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.getFavorites();
});
