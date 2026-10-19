import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;
  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Dapatkan index tab saat ini berdasarkan URL
    final String location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location.startsWith('/search')) currentIndex = 1;
    if (location.startsWith('/watchlist')) currentIndex = 2;
    if (location.startsWith('/profile')) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/search');
          if (index == 2) context.go('/watchlist');
          if (index == 3) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
