import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/movie.dart';

/// Satu entri diary untuk sebuah film pada tanggal tertentu.
class DiaryEntry {
  final int id;
  final Movie movie;
  final String? note;
  final int? rating;
  final String? content;

  DiaryEntry({
    required this.id,
    required this.movie,
    this.note,
    this.rating,
    this.content,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] ?? 0,
      movie: Movie.fromJson(Map<String, dynamic>.from(json['movie'] ?? {})),
      note: json['note'],
      rating: json['rating'],
      content: json['content'],
    );
  }
}

/// Diary dikelompokkan per tanggal tontonan.
class DiaryDay {
  final String watchedDate;
  final List<DiaryEntry> items;

  DiaryDay({required this.watchedDate, required this.items});

  factory DiaryDay.fromJson(Map<String, dynamic> json) {
    final List raw = json['items'] ?? [];
    return DiaryDay(
      watchedDate: json['watched_date']?.toString() ?? '',
      items: raw
          .map((e) => DiaryEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DiaryRepository {
  final ApiClient _api = ApiClient();

  Future<List<DiaryDay>> getDiary() async {
    try {
      final response = await _api.dio.get('/diary');
      final List data = response.data['data'] ?? [];
      return data
          .map((json) => DiaryDay.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat log');
    }
  }
}
