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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash', // Aplikasi dimulai dari Splash Screen
  routes: [
    // 1. Rute Splash Screen (Tanpa Bottom Nav)
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

    // 2. Rute Utama dengan Bottom Navigation Bar
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

    // 3. Rute Detail Film (Tanpa Bottom Nav, Layar Penuh)
    // Menerima parameter ID dari URL (misal: /movie/1)
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final movieId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return MovieDetailPage(movieId: movieId);
      },
    ),

    // 4. Rute Autentikasi (Login)
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  ],
);

void main() {
  // ProviderScope wajib ada untuk menggunakan Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MLBox',
      theme: AppTheme.darkTheme, // Tema gelap #14181C
      routerConfig: appRouter,
      debugShowCheckedModeBanner:
          false, // Menghilangkan banner "Debug" di pojok
    );
  }
}
