import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';

class FavoriteRepository {
  final ApiClient _api = ApiClient();

  /// Film favorit milik user yang sedang login (`GET /api/favorites`).
  ///
  /// Backend mengembalikan objek berisi `movie`, jadi yang dipakai di sini
  /// hanya filmnya.
  Future<List<Movie>> getFavorites() async {
    try {
      final response = await _api.dio.get('/favorites');
      final List data = response.data['data'] ?? [];
      return _parse(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memuat film favorit',
      );
    }
  }

  /// Simpan daftar film favorit beserta urutannya (`PUT /api/favorites`).
  ///
  /// Backend menyimpan maksimal 4 film, jadi list lebih dari itu dipotong.
  /// Daftar kosong tetap dikirim supaya semua favorit bisa dihapus.
  Future<List<Movie>> saveFavorites(List<int> movieIds) async {
    final List<int> ids = movieIds.take(4).toList();

    try {
      final response = await _api.dio.put(
        '/favorites',
        data: {
          'items': [
            for (var i = 0; i < ids.length; i++)
              {'movie_id': ids[i], 'position': i + 1},
          ],
        },
      );
      final List data = response.data['data'] ?? [];
      return _parse(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal menyimpan film favorit',
      );
    }
  }

  static List<Movie> _parse(List data) {
    return data
        .whereType<Map>()
        .map((json) => json['movie'])
        .whereType<Map>()
        .map((json) => Movie.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
