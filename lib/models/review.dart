class Review {
  final int id;
  final String userName;
  final String userAvatar;
  final int rating;
  final String content;
  final String createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userName: json['user']?['name'] ?? 'Anonymous',
      userAvatar:
          'https://ui-avatars.com/api/?name=${json['user']?['name'] ?? 'A'}&background=random',
      rating: json['rating'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
