import 'movie.dart';

/// Satu entri "film yang sudah ditonton": filmnya plus tanggal ditonton.
class WatchedEntry {
  final int id;
  final Movie movie;

  /// Tanggal film ditonton, format `YYYY-MM-DD`.
  final String? watchedAt;

  const WatchedEntry({required this.id, required this.movie, this.watchedAt});

  factory WatchedEntry.fromJson(Map<String, dynamic> json) {
    return WatchedEntry(
      id: json['id'] ?? 0,
      movie: Movie.fromJson(
        Map<String, dynamic>.from(json['movie'] ?? <String, dynamic>{}),
      ),
      watchedAt: json['watched_at']?.toString(),
    );
  }

  /// Tanggal dalam format yang enak dibaca, mis. "20 Okt 2026".
  String get watchedAtLabel {
    final DateTime? parsed = DateTime.tryParse(watchedAt ?? '');
    if (parsed == null) return '';

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }
}
