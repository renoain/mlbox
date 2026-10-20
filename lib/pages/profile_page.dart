import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/profile_stats.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/favorite_posters_section.dart';
import '../widgets/lb_widgets.dart';
import '../widgets/main_bottom_nav.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: LbColors.profileBg,
        body: const _GuestMessage(),
        bottomNavigationBar: const MainBottomNav(currentIndex: 4),
      );
    }

    final statsAsync = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: LbColors.profileBg,
      body: Column(
        children: [
          _Header(
            username: user.name,
            onSettings: () => context.push('/settings'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 22),
                Center(child: _Avatar(name: user.name)),
                const SizedBox(height: 10),
                if (user.createdAt != null)
                  Center(
                    child: Text(
                      'Joined ${_formatDate(user.createdAt!)}',
                      style: const TextStyle(
                        color: LbColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                const _SectionHeader('FAVOURITE FILMS'),
                const FavoritePostersSection(),
                const SizedBox(height: 8),
                statsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: LbColors.green),
                    ),
                  ),
                  error: (error, stackTrace) => _StatsError(
                    message: error.toString().replaceFirst('Exception: ', ''),
                    onRetry: () => ref.invalidate(profileStatsProvider),
                  ),
                  data: (stats) => _StatsRows(stats: stats),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 4),
    );
  }

  static String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Header: ikon setelan di kiri, username di tengah, ikon lain di kanan.
class _Header extends StatelessWidget {
  final String username;
  final VoidCallback onSettings;

  const _Header({required this.username, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LbColors.appBarBlack,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: LbColors.rowLabel,
              ),
              onPressed: onSettings,
            ),
            Expanded(
              child: Text(
                username,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Spacer seukuran tombolnya supaya username tetap terpusat.
            const SizedBox(width: 48),
          ],
        ),
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
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LbColors.segment,
        border: Border.all(color: const Color(0xFF44546A), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: LbColors.rowLabel,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 4, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: LbColors.muted,
          fontSize: 12,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

/// Baris statistik profil.
class _StatsRows extends StatelessWidget {
  final ProfileStats stats;

  const _StatsRows({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Baris yang belum punya halaman sendiri sengaja TANPA chevron,
        // supaya tidak terlihat bisa diklik padahal belum berfungsi.
        const _Row(label: 'Activity', topLine: true),
        const SizedBox(height: 14),
        _Row(
          label: 'Films',
          value: '${stats.totalWatched}',
          topLine: true,
          chevron: true,
          onTap: () => context.go('/watched'),
        ),
        _Row(
          label: 'Diary',
          value: '${stats.totalDiary}',
          chevron: true,
          onTap: () => context.go('/log'),
        ),
        _Row(label: 'Reviews', value: '${stats.totalReviews}'),
        _Row(label: 'Lists', value: '${stats.totalLists}'),
        _Row(
          label: 'Watchlist',
          value: '${stats.totalWatchlist}',
          chevron: true,
          onTap: () => context.go('/watchlist'),
        ),
        _Row(
          label: 'Likes',
          value: '${stats.totalLikes}',
          chevron: true,
          onTap: () => context.go('/likes'),
        ),
        _Row(label: 'Tags', value: '${stats.totalTags}'),
        _Row(label: 'Following', value: '${stats.totalFollowing}'),
        _Row(label: 'Followers', value: '${stats.totalFollowers}'),
        const _Row(label: 'Stats', pro: true, bottomLine: true),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final bool chevron;
  final bool pro;
  final bool topLine;
  final bool bottomLine;

  /// Kalau null, barisnya tidak bisa diklik dan chevron disembunyikan.
  final VoidCallback? onTap;

  const _Row({
    required this.label,
    this.value,
    this.chevron = false,
    this.pro = false,
    this.topLine = false,
    this.bottomLine = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const line = BorderSide(color: LbColors.divider, width: 1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 57,
          padding: const EdgeInsets.only(left: 28, right: 12),
          decoration: BoxDecoration(
            border: Border(top: topLine ? line : BorderSide.none, bottom: line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: LbColors.rowLabel,
                    fontSize: 18,
                  ),
                ),
              ),
              if (pro) ...[
                const Text(
                  'Upgrade to ',
                  style: TextStyle(color: LbColors.muted, fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: LbColors.orange,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (value != null)
                Text(
                  value!,
                  style: const TextStyle(color: LbColors.muted, fontSize: 16),
                ),
              // Chevron hanya muncul kalau barisnya benar-benar bisa diklik.
              if (chevron && onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: LbColors.rowLabel,
                  size: 22,
                )
              else if (value != null)
                const SizedBox(width: 22),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 20, 12),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: LbColors.muted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: LbColors.muted, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
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
              'Masuk untuk melihat profil',
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
                backgroundColor: LbColors.green,
                foregroundColor: Colors.white,
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
