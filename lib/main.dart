import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import Core & Tema
import 'core/app_theme.dart';

// Import Halaman (Pages)
import 'pages/splash_page.dart';
import 'pages/main_navigation.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/watchlist_page.dart';
import 'pages/profile_page.dart';
import 'pages/movie_detail_page.dart';
import 'pages/login_page.dart';
import 'pages/review_form_page.dart'; // <-- TAMBAHAN BARU

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // 1. Splash Screen
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

    // 2. Bottom Navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainNavigation(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: '/watchlist',
          builder: (context, state) => const WatchlistPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // 3. Rute Detail Film
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final movieId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return MovieDetailPage(movieId: movieId);
      },
      // SUB-RUTE UNTUK FORM REVIEW (Akses: /movie/1/review)
      routes: [
        GoRoute(
          path: 'review',
          builder: (context, state) {
            final movieId =
                int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return ReviewFormPage(movieId: movieId);
          },
        ),
      ],
    ),

    // 4. Login
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
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
