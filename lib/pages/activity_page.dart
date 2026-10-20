import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/home_tab_bar.dart';
import '../widgets/main_bottom_nav.dart';
import 'log_page.dart';
import 'watchlist_page.dart';

/// Halaman Activity: gabungan Watchlist dan Diary dalam dua tab.
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          // Header hitam, tab menyatu dengan AppBar (tanpa kotak).
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const LbTabBar(labels: ['Watchlist', 'Diary']),
        ),
        body: isLoggedIn
            ? const TabBarView(children: [WatchlistBody(), LogBody()])
            : const _GuestMessage(),
        // Penanda menu: Activity = index 3.
        bottomNavigationBar: MainBottomNav(currentIndex: isLoggedIn ? 3 : 0),
      ),
    );
  }
}

class _GuestMessage extends StatelessWidget {
  const _GuestMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white38, size: 52),
            const SizedBox(height: 16),
            const Text(
              'Masuk untuk melihat activity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                minimumSize: const Size(160, 50),
              ),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}
