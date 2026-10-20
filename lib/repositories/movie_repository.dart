import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';

class MovieRepository {
  final ApiClient _api = ApiClient();

  /// Jumlah film per halaman. Backend memaginasi, jadi angka ini harus
  /// cukup besar agar seluruh katalog (52 film) sekaligus termuat.
  static const int perPage = 100;

  // 1. Ambil Daftar Film (Home)
  Future<List<Movie>> getMovies() async {
    try {
      final response = await _api.dio.get(
        '/movies',
        queryParameters: {'per_page': perPage},
      );
      return _parseList(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat film');
    }
  }

  // 2. Ambil Detail Satu Film (Misal: /movies/1)
  Future<Movie> getMovieDetail(int id) async {
    try {
      final response = await _api.dio.get('/movies/$id');
      final data = response.data['data'];
      if (data is! Map) {
        throw Exception('Data film tidak valid');
      }
      return Movie.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memuat detail film',
      );
    }
  }

  // 3. Beri / ubah rating bintang pada sebuah film.
  Future<int> rateMovie(int movieId, int rating) async {
    try {
      final response = await _api.dio.post(
        '/movies/$movieId/rate',
        data: {'rating': rating},
      );
      return response.data['data']['rating'] ?? rating;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menyimpan rating');
    }
  }

  // 4. Hapus rating bintang pada sebuah film.
  Future<void> unrateMovie(int movieId) async {
    try {
      await _api.dio.delete('/movies/$movieId/rate');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus rating');
    }
  }

  /// Backend membungkus daftar film di `data`. Bentuk lain yang dibungkus
  /// (mis. `data.items`) tetap diterima supaya parsing tidak rapuh.
  static List<Movie> _parseList(dynamic body) {
    dynamic payload = body is Map ? body['data'] : body;

    if (payload is Map) {
      payload =
          payload['items'] ?? payload['data'] ?? payload['results'] ?? payload;
    }
    if (payload is! List) {
      return const [];
    }

    return payload
        .whereType<Map>()
        .map((json) => Movie.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
