import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';

class MovieRepository {
  final ApiClient _api = ApiClient();

  // 1. Ambil Daftar Film (Home)
  Future<List<Movie>> getMovies() async {
    try {
      final response = await _api.dio.get('/movies');
      final List data = response.data['data'] ?? [];
      return data.map((json) => Movie.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat film');
    }
  }

  // 2. Ambil Detail Satu Film (Misal: /movies/1)
  Future<Movie> getMovieDetail(int id) async {
    try {
      final response = await _api.dio.get('/movies/$id');
      return Movie.fromJson(response.data['data']);
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
}
