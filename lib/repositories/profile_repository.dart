import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/profile_stats.dart';

class ProfileRepository {
  final ApiClient _api = ApiClient();

  /// Statistik profil (jumlah watched, watchlist, review, dll).
  Future<ProfileStats> getStats() async {
    try {
      final response = await _api.dio.get('/profile/stats');
      final dynamic data = response.data['data'];
      return ProfileStats.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memuat statistik profil',
      );
    }
  }
}
