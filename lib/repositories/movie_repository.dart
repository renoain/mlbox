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

  // 5. Tandai film sebagai liked.
  Future<void> likeMovie(int movieId) async {
    try {
      await _api.dio.post('/likes', data: _likePayload(movieId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menyimpan like');
    }
  }

  // 6. Hapus like pada sebuah film.
  Future<void> unlikeMovie(int movieId) async {
    try {
      await _api.dio.delete('/likes', data: _likePayload(movieId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus like');
    }
  }

  // 7. Daftar film yang sudah dilike user yang sedang login.
  Future<List<Movie>> getLikedMovies() async {
    try {
      final response = await _api.dio.get('/likes');
      final List data = response.data['data'] ?? [];
      return data
          .whereType<Map>()
          .where((json) => json['likeable_type'] == _movieLikeType)
          .map((json) => json['movie'])
          .whereType<Map>()
          .map((json) => Movie.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memuat daftar like',
      );
    }
  }

  // Endpoint like bersifat polymorphic, jadi tipe target harus ikut dikirim.
  // Nilainya adalah nama class model di backend.
  static const String _movieLikeType = 'App\\Models\\Movie';

  static Map<String, dynamic> _likePayload(int movieId) {
    return {'likeable_id': movieId, 'likeable_type': _movieLikeType};
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
