import '../core/api_config.dart';

class Movie {
  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterUrl;
  final String? backdropUrl;
  final String? releaseDate;
  final int? runtime;
  final String? genres;
  final List<String> cast;
  final String? crew;
  final String? language;
  final String? country;
  final bool isFeatured;
  final double? averageRating;
  final int reviewCount;
  final int watchedCount;
  final int watchlistCount;

  Movie({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterUrl,
    this.backdropUrl,
    this.releaseDate,
    this.runtime,
    this.genres,
    this.cast = const [],
    this.crew,
    this.language,
    this.country,
    this.isFeatured = false,
    this.averageRating,
    this.reviewCount = 0,
    this.watchedCount = 0,
    this.watchlistCount = 0,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      originalTitle: json['original_title'],
      overview: json['overview'],
      // Backend mengirim URL lengkap
      // (`http://.../api/media/posters/x.jpg`), tapi path relatif tetap
      // diterima supaya aman kalau format payload berubah.
      posterUrl: ApiConfig.resolveAssetUrl(
        json['poster_url'] ?? json['poster'] ?? json['poster_path'],
      ),
      backdropUrl: ApiConfig.resolveAssetUrl(
        json['backdrop_url'] ?? json['backdrop_path'],
      ),
      releaseDate: json['release_date'],
      runtime: json['runtime'],
      genres: json['genres'] is List
          ? (json['genres'] as List)
                .map((g) => g is Map ? g['name'] : g)
                .where((g) => g != null)
                .join(', ')
          : json['genres']?.toString(),
      cast: _parseCast(json['cast']),
      crew: json['crew']?.toString(),
      language: json['language']?.toString(),
      country: json['country']?.toString(),
      isFeatured: json['is_featured'] == true,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      watchedCount: json['watched_count'] ?? 0,
      watchlistCount: json['watchlist_count'] ?? 0,
    );
  }

  /// Cast disimpan backend sebagai teks yang dipisah koma
  /// (`"Aktor A, Aktor B"`), tapi list juga diterima.
  static List<String> _parseCast(dynamic value) {
    if (value == null) return const [];

    if (value is List) {
      return value
          .map(
            (item) => item is Map ? item['name']?.toString() : item.toString(),
          )
          .whereType<String>()
          .where((name) => name.trim().isNotEmpty)
          .toList();
    }

    return value
        .toString()
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
