import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/main_bottom_nav.dart';
import '../providers/auth_provider.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    return Scaffold(
      backgroundColor: const Color(0xFF14181C),
      appBar: AppBar(title: const Text('Watchlist')),
      body: const Center(
        child: Text('Halaman Watchlist', style: TextStyle(color: Colors.white)),
      ),
      // Penanda menu: Watchlist = index 2 untuk user login, Users = index 0 untuk guest.
      bottomNavigationBar: MainBottomNav(currentIndex: isLoggedIn ? 2 : 0),
    );
  }
}
