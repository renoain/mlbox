import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/register_page.dart';
import 'pages/settings_page.dart';

void main() => runApp(const PreviewApp());

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (c, s) => const _Menu()),
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterPage()),
    GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
    GoRoute(
      path: '/home',
      builder: (c, s) => const Scaffold(body: Center(child: Text('Home'))),
    ),
  ],
);

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routerConfig: _router,
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in ['login', 'register', 'profile', 'settings'])
              Padding(
                padding: const EdgeInsets.all(6),
                child: ElevatedButton(
                  onPressed: () => context.push('/$p'),
                  child: Text(p.toUpperCase()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
