import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';
import '../models/review.dart';

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

  // 3. Ambil Review Film (Jika backend mendukung)
  Future<List<Review>> getMovieReviews(int movieId) async {
    try {
      final response = await _api.dio.get('/movies/$movieId/reviews');
      final List data = response.data['data'] ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Gagal memuat review');
    }
  }
}
