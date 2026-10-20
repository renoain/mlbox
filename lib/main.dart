import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/app_theme.dart';
import 'pages/activity_page.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/watchlist_page.dart';
import 'pages/watched_page.dart';
import 'pages/log_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/movie_detail_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/likes_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/review_form_page.dart';

final appRouter = GoRouter(
  // Aplikasi dibuka lewat onboarding dulu. User yang sudah login otomatis
  // dilewati oleh OnboardingPage dan langsung masuk ke /home.
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
    GoRoute(
      path: '/watchlist',
      builder: (context, state) => const WatchlistPage(),
    ),
    GoRoute(path: '/log', builder: (context, state) => const LogPage()),
    GoRoute(
      path: '/activity',
      builder: (context, state) => const ActivityPage(),
    ),
    GoRoute(path: '/watched', builder: (context, state) => const WatchedPage()),
    GoRoute(path: '/likes', builder: (context, state) => const LikesPage()),
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
