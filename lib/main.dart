import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/app_theme.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/search_results_page.dart';
import 'pages/activity_page.dart';
import 'pages/add_film_page.dart';
import 'pages/featured_lists_page.dart';
import 'pages/official_lists_page.dart';
import 'pages/watchlist_page.dart';
import 'pages/log_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/movie_detail_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/review_form_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
    GoRoute(
      path: '/search/results',
      builder: (context, state) => const SearchResultsPage(),
    ),
    GoRoute(path: '/activity', builder: (context, state) => const ActivityPage()),
    GoRoute(path: '/add', builder: (context, state) => const AddFilmPage()),
    GoRoute(
      path: '/lists/featured',
      builder: (context, state) => const FeaturedListsPage(),
    ),
    GoRoute(
      path: '/lists/official',
      builder: (context, state) => const OfficialListsPage(),
    ),
    GoRoute(
      path: '/watchlist',
      builder: (context, state) => const WatchlistPage(),
    ),
    GoRoute(path: '/log', builder: (context, state) => const LogPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final movieId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return MovieDetailPage(movieId: movieId);
      },
      routes: [
        GoRoute(
          path: 'review',
          builder: (context, state) {
            final movieId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return ReviewFormPage(movieId: movieId);
          },
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MLBox',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
