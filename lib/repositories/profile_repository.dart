import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/profile_stats.dart';
import '../models/review.dart';

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

  /// Review yang pernah ditulis user yang sedang login.
  ///
  /// Endpoint-nya sama dengan `GET /reviews`, tapi di sini dipanggil lewat
  /// route profil supaya jelas review miliknya siapa.
  Future<List<Review>> getReviews() async {
    try {
      final response = await _api.dio.get('/profile/reviews');
      final dynamic data = response.data['data'];

      final List items = data is List
          ? data
          : (data is Map ? (data['data'] as List? ?? const []) : const []);

      return items
          .whereType<Map>()
          .map((json) => Review.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memuat daftar review',
      );
    }
  }
}
