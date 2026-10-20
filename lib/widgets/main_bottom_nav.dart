import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart'; // <-- Panggil AuthProvider

class MainBottomNav extends ConsumerWidget {
  final int currentIndex;

  const MainBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengecek apakah user sudah login atau belum
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    return SafeArea(
      top: false,
      child: BottomNavigationBar(
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        elevation: 0,
        onTap: (index) {
          if (!isLoggedIn) {
            // NAVBAR GUEST (3 Ikon)
            if (index == 0) context.go('/login');
            if (index == 1) context.go('/home');
            if (index == 2) context.go('/search');
          } else {
            // NAVBAR USER LOGIN (5 Ikon)
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/search');
            if (index == 2) context.go('/watchlist');
            if (index == 3) context.go('/log');
            if (index == 4) context.go('/profile');
          }
        },
        items: isLoggedIn
            ? const [
                // 5 Ikon untuk yang sudah login
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_outlined),
                  activeIcon: Icon(Icons.movie),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border),
                  activeIcon: Icon(Icons.bookmark),
                  label: 'Watchlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Log',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : const [
                // 3 Ikon untuk Guest (Belum Login)
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_outlined),
                  activeIcon: Icon(Icons.movie),
                  label: 'Films',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
      ),
    );
  }
}
