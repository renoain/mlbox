import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_stats.dart';
import '../repositories/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

/// Statistik profil user yang sedang login.
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getStats();
});
