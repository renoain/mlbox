class Review {
  final int id;
  final int movieId;
  final String userName;
  final int rating;
  final String content;
  final String createdAt;

  Review({
    required this.id,
    required this.movieId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      movieId: json['movie_id'] ?? 0,
      userName: json['user_name']?.toString() ?? 'Anonymous',
      rating: (json['rating'] ?? 0) as int,
      content: json['content']?.toString() ?? '',
      createdAt: json['updated_at']?.toString() ?? '',
    );
  }
}
