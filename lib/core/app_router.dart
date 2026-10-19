import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/movie_detail_page.dart';

// ROUTER SEMENTARA: Bisa lompat ke semua halaman
final appRouter = GoRouter(
  initialLocation: '/home', // LANGSUNG KE HOME
  routes: [
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) => const MovieDetailPage(),
    ),
    // Tambahkan /profile, /search, dll di sini nanti
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
    );
  }
}
