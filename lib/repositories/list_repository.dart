import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie_list.dart';

class ListRepository {
  final ApiClient _api = ApiClient();

  /// Kurasi milik user yang sedang login. Endpoint ini butuh token.
  Future<List<MovieList>> getMyLists() async {
    try {
      final response = await _api.dio.get('/lists');
      final List data = response.data['data'] ?? [];
      return data
          .map((json) => MovieList.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat daftar');
    }
  }

  /// Buat kurasi baru.
  Future<MovieList> createList({
    required String title,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final response = await _api.dio.post(
        '/lists',
        data: {
          'title': title,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          'is_public': isPublic,
        },
      );

      final data = response.data['data'];
      return MovieList.fromJson(
        Map<String, dynamic>.from(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal membuat daftar');
    }
  }

  /// Masukkan film ke dalam list (`POST /api/lists/{id}/items`).
  Future<void> addItemToList(int listId, int movieId, {String? note}) async {
    try {
      await _api.dio.post(
        '/lists/$listId/items',
        data: {
          'movie_id': movieId,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal menambahkan film ke list',
      );
    }
  }
}
