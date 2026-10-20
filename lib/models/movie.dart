class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterUrl;
  final String? releaseDate;
  final int? runtime;
  final String? genres;

  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterUrl,
    this.releaseDate,
    this.runtime,
    this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      overview: json['overview'],
      posterUrl: json['poster_url'],
      releaseDate: json['release_date'],
      runtime: json['runtime'],
      genres: json['genres'] is List
          ? (json['genres'] as List).join(', ')
          : json['genres']?.toString(),
    );
  }

  static List<Movie> dummyMovies = [
    Movie(
      id: 1,
      title: 'Inception',
      overview: 'Seorang pencuri yang mencuri informasi dari alam bawah sadar.',
      posterUrl:
          'https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
      releaseDate: '2010-11-05',
      runtime: 148,
      genres: 'Action, Sci-Fi',
    ),
  ];
}
