import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';
import '../models/watched_entry.dart';

class WatchedRepository {
  final ApiClient _api = ApiClient();

  Future<List<Movie>> getWatched() async {
    try {
      final response = await _api.dio.get('/watched');
      final List data = response.data['data'] ?? [];
      return data
          .map((json) => json['movie'])
          .whereType<Map>()
          .map((json) => Movie.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memuat daftar watched',
      );
    }
  }

  /// Daftar film yang sudah ditonton beserta tanggalnya.
  Future<List<WatchedEntry>> getWatchedEntries() async {
    try {
      final response = await _api.dio.get('/watched');
      final List data = response.data['data'] ?? [];
      return data
          .whereType<Map>()
          .map((json) => WatchedEntry.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memuat daftar watched',
      );
    }
  }

  Future<void> markWatched(int movieId) async {
    try {
      await _api.dio.post('/watched', data: {'movie_id': movieId});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menandai watched');
    }
  }

  Future<void> unwatch(int movieId) async {
    try {
      await _api.dio.delete('/watched/$movieId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus watched');
    }
  }
}
