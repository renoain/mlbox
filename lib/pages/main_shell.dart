import 'dart:async';

import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/letterboks_bottom_nav.dart';
import '../widgets/transitions.dart';
import 'activity_page.dart';
import 'add_film_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

/// Cangkang utama: IndexedStack + bottom nav.
///  - Guest (3 item): ikon akun TIDAK pindah tab, langsung membuka halaman login.
///  - Member (5 item): Films, Search, Add (+), Activity, Profile.
/// Daftarkan sebagai route '/' di go_router:
///   GoRoute(path: '/', builder: (context, state) => const MainShell())
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const List<AppTab> _pageTabs = [
    AppTab.films,
    AppTab.search,
    AppTab.activity,
    AppTab.profile,
  ];

  AppTab _selected = AppTab.films;
  bool _bannerVisible = false;
  bool _bannerShown = false;
  bool _loginOpen = false;
  Timer? _showTimer;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    AppState.isLoggedIn.addListener(_onAuthChanged);
    AppState.tabRequest.addListener(_onTabRequest);
    // Soft reminder untuk guest, cukup sekali per sesi.
    _showTimer = Timer(const Duration(seconds: 6), _maybeShowBanner);
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    AppState.isLoggedIn.removeListener(_onAuthChanged);
    AppState.tabRequest.removeListener(_onTabRequest);
    super.dispose();
  }

  void _maybeShowBanner() {
    if (!mounted || AppState.isLoggedIn.value || _bannerShown) return;
    setState(() {
      _bannerVisible = true;
      _bannerShown = true;
    });
    _hideTimer = Timer(const Duration(seconds: 8), _hideBanner);
  }

  void _hideBanner() {
    if (mounted) setState(() => _bannerVisible = false);
  }

  void _onAuthChanged() {
    setState(() {
      _selected = AppTab.films;
      _bannerVisible = false;
    });
  }

  void _onTabRequest() {
    final tab = AppState.tabRequest.value;
    if (tab == null) return;
    AppState.tabRequest.value = null;
    if (tab == AppTab.account) {
      if (!AppState.isLoggedIn.value) _openLogin();
      return;
    }
    if (tab == AppTab.add) {
      _openAdd();
      return;
    }
    final allowed = LetterboksBottomNav.tabsFor(AppState.isLoggedIn.value);
    if (allowed.contains(tab)) setState(() => _selected = tab);
  }

  Future<void> _openLogin() async {
    if (_loginOpen) return;
    _loginOpen = true;
    await Navigator.of(context).push(slideUpRoute<void>(const LoginPage()));
    _loginOpen = false;
  }

  void _openAdd() {
    Navigator.of(context).push(fadeSlideRoute<void>(const AddFilmPage()));
  }

  void _onTap(AppTab tab) {
    if (tab == AppTab.account) {
      _openLogin();
    } else if (tab == AppTab.add) {
      _openAdd();
    } else {
      setState(() => _selected = tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = AppState.isLoggedIn.value;
    final pageIndex = _pageTabs.indexOf(_selected);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          IndexedStack(
            index: pageIndex < 0 ? 0 : pageIndex,
            children: const [
              HomePage(),
              SearchPage(),
              ActivityPage(),
              ProfilePage(),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: IgnorePointer(
              ignoring: !_bannerVisible,
              child: AnimatedSlide(
                offset: _bannerVisible ? Offset.zero : const Offset(0, 1.6),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _bannerVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: _GuestBanner(
                    onSignIn: () {
                      _hideBanner();
                      _openLogin();
                    },
                    onClose: _hideBanner,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LetterboksBottomNav(
        loggedIn: loggedIn,
        selected: _selected,
        onTap: _onTap,
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onClose;

  const _GuestBanner({required this.onSignIn, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
        child: Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.green, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Sign in to rate and review films.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: onSignIn,
              child: const Text(
                'Sign in',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.muted, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
