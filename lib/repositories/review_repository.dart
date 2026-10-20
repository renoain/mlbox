import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/review.dart';

class ReviewRepository {
  final ApiClient _api = ApiClient();

  /// Simpan rating + review baru untuk sebuah film.
  Future<Review> createReview({
    required int movieId,
    required int rating,
    String? content,
  }) async {
    try {
      final response = await _api.dio.post(
        '/reviews',
        data: {
          'movie_id': movieId,
          'rating': rating,
          if (content != null && content.trim().isNotEmpty)
            'content': content.trim(),
        },
      );
      final data = response.data['data'];
      return Review.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menyimpan review');
    }
  }

  /// Daftar review milik user yang sedang login.
  Future<List<Review>> getMyReviews() async {
    try {
      final response = await _api.dio.get('/reviews');
      final List data = response.data['data'] ?? [];
      return data
          .map((json) => Review.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat review');
    }
  }
}
