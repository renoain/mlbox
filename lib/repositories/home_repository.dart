import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';

/// Data beranda terkurasi dari `GET /home`, berisi beberapa section film.
class HomeData {
  final List<Movie> featured;
  final List<Movie> latest;
  final List<Movie> topRated;
  final List<Movie> mostWatched;
  final List<Movie> mostWatchlisted;
  final List<Movie> explore;

  HomeData({
    required this.featured,
    required this.latest,
    required this.topRated,
    required this.mostWatched,
    required this.mostWatchlisted,
    required this.explore,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<Movie> section(String key) {
      final List data = json[key] ?? [];
      return data
          .map((e) => Movie.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return HomeData(
      featured: section('featured'),
      latest: section('latest'),
      topRated: section('top_rated'),
      mostWatched: section('most_watched'),
      mostWatchlisted: section('most_watchlisted'),
      explore: section('explore'),
    );
  }

  bool get isEmpty =>
      featured.isEmpty &&
      latest.isEmpty &&
      mostWatched.isEmpty &&
      mostWatchlisted.isEmpty &&
      explore.isEmpty;
}

class HomeRepository {
  final ApiClient _api = ApiClient();

  Future<HomeData> getHome() async {
    try {
      final response = await _api.dio.get('/home');
      return HomeData.fromJson(
        Map<String, dynamic>.from(response.data['data'] ?? {}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat beranda');
    }
  }
}
