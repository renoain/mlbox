import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Tunggu 1.5 detik agar logo terlihat
    await Future.delayed(const Duration(milliseconds: 1500));

    // Cek status login (dari AuthProvider)
    await ref.read(authProvider.notifier).checkAuthStatus();

    if (mounted) {
      // SELALU masuk ke home (karena kita pakai Guest Mode)
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Text(
          'MLBox',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
