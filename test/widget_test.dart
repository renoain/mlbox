import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mlbox/pages/login_page.dart';
import 'package:mlbox/pages/register_page.dart';
import 'package:mlbox/pages/settings_page.dart';
import 'package:mlbox/widgets/main_bottom_nav.dart';

void main() {
  testWidgets('Guest: Users menu opens Login', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/search', builder: (_, _) => const _SearchStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    // Tap "Users" (index 0) on the guest navbar.
    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to MLBox'), findsOneWidget);
  });

  testWidgets('Guest: Join MLBox opens Register and back returns to Login', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/search', builder: (_, _) => const _SearchStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    await tester.tap(find.text('Join MLBox'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to MLBox'), findsOneWidget);
  });

  testWidgets('Login: empty submit shows validation, no navigation', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const _HomeStub()),
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
        GoRoute(path: '/search', builder: (_, _) => const _SearchStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    await tester.tap(find.text('Go'));
    await tester.pump();

    expect(find.text('Email dan password wajib diisi.'), findsOneWidget);
    expect(find.text('Sign in to MLBox'), findsOneWidget);
  });

  testWidgets('Settings: placeholder item shows not-available message', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        GoRoute(path: '/profile', builder: (_, _) => const _HomeStub()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Edit Profile'));
    await tester.pump();

    expect(find.text('Fitur belum tersedia.'), findsOneWidget);
  });
}

class _HomeStub extends StatelessWidget {
  const _HomeStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Text('Home'),
    bottomNavigationBar: MainBottomNav(currentIndex: 1),
  );
}

class _SearchStub extends StatelessWidget {
  const _SearchStub();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Search'));
}
