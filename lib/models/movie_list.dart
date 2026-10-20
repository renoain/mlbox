/// Kurasi film buatan user, diambil dari `GET /api/lists`.
class MovieList {
  final int id;
  final String title;
  final String? description;
  final String ownerName;
  final int itemCount;
  final int likesCount;
  final bool isPublic;
  final String createdAt;

  const MovieList({
    required this.id,
    required this.title,
    this.description,
    this.ownerName = '',
    this.itemCount = 0,
    this.likesCount = 0,
    this.isPublic = false,
    this.createdAt = '',
  });

  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Tanpa Judul',
      description: json['description']?.toString(),
      ownerName: json['owner_name']?.toString() ?? '',
      itemCount: json['item_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      isPublic: json['is_public'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
