import 'package:flutter/foundation.dart';

enum AppTab { account, films, search, add, activity, profile }

class ActivityEntry {
  final String user;
  final String title;
  final int year;
  final double rating;
  final bool liked;
  final String review;
  final String? posterUrl;
  final DateTime watchedOn;

  const ActivityEntry({
    this.user = 'You',
    required this.title,
    required this.year,
    required this.rating,
    required this.liked,
    required this.review,
    this.posterUrl,
    required this.watchedOn,
  });
}

/// State global sederhana (tanpa dependency tambahan).
/// Nanti bisa diganti Riverpod / auth beneran.
class AppState {
  AppState._();

  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<AppTab?> tabRequest = ValueNotifier<AppTab?>(null);
  static final ValueNotifier<List<ActivityEntry>> activities =
      ValueNotifier<List<ActivityEntry>>(const []);
  static final ValueNotifier<List<String>> recentSearches =
      ValueNotifier<List<String>>(const ['jo']);

  static void goTo(AppTab tab) {
    tabRequest.value = tab;
  }

  static void addActivity(ActivityEntry entry) {
    activities.value = [entry, ...activities.value];
  }

  static void addRecent(String query) {
    final v = query.trim();
    if (v.isEmpty) return;
    final next = <String>[
      v,
      ...recentSearches.value.where((e) => e.toLowerCase() != v.toLowerCase()),
    ];
    recentSearches.value = next.take(8).toList();
  }
}
