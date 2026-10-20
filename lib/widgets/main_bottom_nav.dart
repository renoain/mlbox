import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'movie_picker_sheet.dart';

/// Bottom navigation dengan lima menu:
///
/// 0 = Home, 1 = Search, 2 = Quick Review, 3 = Activity, 4 = Profile.
///
/// Ikon aktif memakai gaya *filled* dan dibungkus kapsul biru gelap.
/// Ikon tidak aktif memakai gaya *outline* berwarna abu-abu.
/// Tombol tengah (Quick Review) selalu hijau dan tidak memakai kapsul.
class MainBottomNav extends ConsumerWidget {
  final int currentIndex;

  const MainBottomNav({super.key, required this.currentIndex});

  /// Warna ikon untuk halaman yang sedang aktif.
  static const Color activeColor = Color(0xFF40BCF4);

  /// Warna ikon untuk halaman lain.
  static const Color inactiveColor = Color(0xFF9AB5C4);

  /// Warna latar kapsul ikon aktif.
  static const Color capsuleColor = Color(0xFF1A3B4F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoggedIn = ref.watch(authProvider).isAuthenticated;

    return Container(
      decoration: BoxDecoration(
        // Gradasi dari transparan di atas ke gelap pekat di bawah, supaya
        // navbar terlihat melayang di atas konten.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppTheme.background],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) => _onTap(context, ref, index),
          items: isLoggedIn ? _memberItems() : _guestItems(),
        ),
      ),
    );
  }

  /// Lima menu untuk user yang sudah login.
  List<BottomNavigationBarItem> _memberItems() {
    return [
      BottomNavigationBarItem(
        icon: _CapsuleIcon(
          activeIcon: Icons.video_library,
          inactiveIcon: Icons.video_library_outlined,
          isActive: currentIndex == 0,
        ),
        label: 'Library',
      ),
      BottomNavigationBarItem(
        icon: _CapsuleIcon(
          activeIcon: Icons.search,
          inactiveIcon: Icons.search,
          isActive: currentIndex == 1,
        ),
        label: 'Search',
      ),
      // Tombol tengah: warna hijau statis, lebih besar, tanpa kapsul.
      BottomNavigationBarItem(
        icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 32),
        label: 'Review',
      ),
      BottomNavigationBarItem(
        icon: _CapsuleIcon(
          activeIcon: Icons.bolt,
          inactiveIcon: Icons.bolt_outlined,
          isActive: currentIndex == 3,
        ),
        label: 'Activity',
      ),
      BottomNavigationBarItem(
        icon: _CapsuleIcon(
          activeIcon: Icons.person,
          inactiveIcon: Icons.person_outline,
          isActive: currentIndex == 4,
        ),
        label: 'Profile',
      ),
    ];
  }

  /// Tiga menu untuk guest: Home, Search, dan Account.
  ///
  /// Ikon memakai komponen _CapsuleIcon yang sama, jadi tampilan kapsul
  /// biru dan gradasinya identik dengan versi lima ikon.
  List<BottomNavigationBarItem> _guestItems() {
    return [
      BottomNavigationBarItem(
        icon: _CapsuleIcon(
          activeIcon: Icons.people,
          inactiveIcon: Icons.people_outline,
          isActive: currentIndex == 0,
        ),
        label: 'Login',
      ),
      BottomNavigationBarItem(
        icon: _CapsuleIcon(
          activeIcon: Icons.video_library,
          inactiveIcon: Icons.video_library_outlined,
          isActive: currentIndex == 1,
        ),
        label: 'Library',
      ),
      BottomNavigationBarItem(
        icon: _CapsuleIcon(
          activeIcon: Icons.search,
          inactiveIcon: Icons.search,
          isActive: currentIndex == 2,
        ),
        label: 'Search',
      ),
    ];
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref, int index) async {
    final bool isLoggedIn = ref.read(authProvider).isAuthenticated;

    if (!isLoggedIn) {
      // NAVBAR GUEST (3 Ikon): Login, Library, Search
      switch (index) {
        case 0:
          context.go('/login');
        case 1:
          context.go('/home');
        case 2:
          context.go('/search');
      }
      return;
    }

    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/search');
      case 2:
        await _openQuickReview(context, ref);
      case 3:
        context.go('/activity');
      case 4:
        context.go('/profile');
    }
  }

  /// Quick Review: pilih film, lalu langsung buka form reviewnya.
  Future<void> _openQuickReview(BuildContext context, WidgetRef ref) async {
    if (!ref.read(authProvider).isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masuk dulu untuk menulis review.'),
          action: SnackBarAction(
            label: 'Masuk',
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }

    final movie = await showMoviePicker(
      context,
      title: 'Pilih film untuk di-review',
    );

    if (movie == null || !context.mounted) return;

    context.push('/movie/${movie.id}/review');
  }
}

/// Ikon navbar dengan kapsul di belakang saat aktif.
///
/// Kapsulnya memakai `AnimatedContainer` supaya transisi warnanya halus.
class _CapsuleIcon extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool isActive;

  const _CapsuleIcon({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? MainBottomNav.capsuleColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        isActive ? activeIcon : inactiveIcon,
        color: isActive
            ? MainBottomNav.activeColor
            : MainBottomNav.inactiveColor,
        size: 24,
      ),
    );
  }
}
