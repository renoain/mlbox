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
}
