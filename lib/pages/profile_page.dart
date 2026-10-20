import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/profile_stats.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/main_bottom_nav.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Silakan masuk untuk melihat profil.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : _ProfileBody(name: user.name, email: user.email),
      bottomNavigationBar: user == null
          ? const MainBottomNav(currentIndex: 0)
          : const MainBottomNav(currentIndex: 4),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final String name;
  final String email;

  const _ProfileBody({required this.name, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      onRefresh: () async {
        ref.invalidate(profileStatsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Avatar + nama + email
          Column(
            children: [
              _Avatar(name: name),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Statistik
          statsAsync.when(
            loading: () => const SizedBox(
              height: 90,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            ),
            error: (error, stackTrace) => _StatsError(
              message: error.toString().replaceFirst('Exception: ', ''),
              onRetry: () => ref.invalidate(profileStatsProvider),
            ),
            data: (stats) => _StatsGrid(stats: stats),
          ),

          const SizedBox(height: 32),

          // Logout
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.error,
            ),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('LOG OUT'),
          ),
        ],
      ),
    );
  }
}

/// Avatar bulat berisi inisial nama.
class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final String trimmed = name.trim();
    final String initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.primary, width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Grid statistik: watched, watchlist, review, list.
class _StatsGrid extends StatelessWidget {
  final ProfileStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final List<_StatItem> items = [
      _StatItem(
        label: 'WATCHED',
        value: stats.totalWatched,
        icon: Icons.done_all,
      ),
      _StatItem(
        label: 'WATCHLIST',
        value: stats.totalWatchlist,
        icon: Icons.bookmark_border,
      ),
      _StatItem(
        label: 'REVIEWS',
        value: stats.totalReviews,
        icon: Icons.rate_review_outlined,
      ),
      _StatItem(
        label: 'LISTS',
        value: stats.totalLists,
        icon: Icons.list_alt_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _StatTile(item: items[index]),
    );
  }
}

class _StatItem {
  final String label;
  final int value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _StatTile extends StatelessWidget {
  final _StatItem item;

  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StatsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
