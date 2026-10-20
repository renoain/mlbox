import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Tab bar transparan ala Letterboxd.
///
/// Tanpa kotak-kotak: background-nya transparan dan menyatu dengan header
/// hitam. Teks tab aktif berwarna putih dengan garis bawah hijau tipis, tab
/// tidak aktif berwarna abu-abu.
///
/// Karena implements [PreferredSizeWidget], bisa langsung dipakai sebagai
/// `AppBar.bottom`:
/// ```dart
/// AppBar(
///   backgroundColor: Colors.black,
///   bottom: LbTabBar(labels: ['Films', 'Reviews']),
/// )
/// ```
///
/// Untuk tab yang bisa digeser (swipe), pasangkan dengan `TabBarView` di
/// dalam `DefaultTabController`.
class LbTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> labels;

  const LbTabBar({super.key, required this.labels});

  /// Tinggi tab bar, dipakai `AppBar.bottom` supaya AppBar tahu alokasinya.
  @override
  Size get preferredSize => const Size.fromHeight(46);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: false,
      // Garis hijau tipis, selebar teks tab.
      indicatorColor: AppTheme.primary,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.white,
      unselectedLabelColor: AppTheme.textSecondary,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      // Hilangkan garis pemisah bawaan Material 3.
      dividerColor: Colors.transparent,
      splashBorderRadius: BorderRadius.zero,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabs: [for (final String label in labels) Tab(text: label)],
    );
  }
}
