/// Statistik profil user, diambil dari `GET /api/profile/stats`.
class ProfileStats {
  final int totalWatched;
  final int totalWatchlist;
  final int totalDiary;
  final int totalReviews;
  final int totalLists;
  final int totalLikes;
  final int totalFollowers;
  final int totalFollowing;
  final double averageRating;

  const ProfileStats({
    this.totalWatched = 0,
    this.totalWatchlist = 0,
    this.totalDiary = 0,
    this.totalReviews = 0,
    this.totalLists = 0,
    this.totalLikes = 0,
    this.totalFollowers = 0,
    this.totalFollowing = 0,
    this.averageRating = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalWatched: json['total_watched'] ?? 0,
      totalWatchlist: json['total_watchlist'] ?? 0,
      totalDiary: json['total_diary'] ?? 0,
      totalReviews: json['total_reviews'] ?? 0,
      totalLists: json['total_lists'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      totalFollowers: json['total_followers'] ?? 0,
      totalFollowing: json['total_following'] ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
