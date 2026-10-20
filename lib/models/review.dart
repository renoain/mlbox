import 'movie.dart';

class Review {
  final int id;
  final int movieId;
  final String userName;
  final int rating;
  final String content;
  final String createdAt;
  final int likesCount;

  /// Film yang direview. Null kalau endpoint tidak menyertakan film.
  final Movie? movie;

  Review({
    required this.id,
    required this.movieId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.movie,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final movieJson = json['movie'];

    return Review(
      id: json['id'] ?? 0,
      movieId: json['movie_id'] ?? 0,
      userName: json['user_name']?.toString() ?? 'Anonymous',
      // Rating boleh null kalau user menghapus bintangnya, jadi selalu aman.
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      content: json['content']?.toString() ?? '',
      createdAt: json['updated_at']?.toString() ?? '',
      likesCount: json['likes_count'] ?? 0,
      movie: movieJson is Map
          ? Movie.fromJson(Map<String, dynamic>.from(movieJson))
          : null,
    );
  }
}
