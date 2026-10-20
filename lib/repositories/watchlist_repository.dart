import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';

class WatchlistRepository {
  final ApiClient _api = ApiClient();

  Future<List<Movie>> getWatchlist() async {
    try {
      final response = await _api.dio.get('/watchlist');
      final List data = response.data['data'] ?? [];
      return data
          .map((json) => json['movie'])
          .whereType<Map>()
          .map((json) => Movie.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat watchlist');
    }
  }

  Future<void> add(int movieId) async {
    try {
      await _api.dio.post('/watchlist', data: {'movie_id': movieId});
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal menambah ke watchlist',
      );
    }
  }

  Future<void> remove(int movieId) async {
    try {
      await _api.dio.delete('/watchlist/$movieId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal menghapus dari watchlist',
      );
    }
  }
}
