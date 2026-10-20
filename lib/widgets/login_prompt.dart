import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_language.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

/// Pengecek login untuk tombol aksi yang butuh akun.
///
/// Mengembalikan `true` kalau user sudah login, jadi aksi aslinya bisa
/// langsung dijalankan. Kalau belum login, munculkan sheet ajakan masuk dan
/// mengembalikan `false` sehingga aksi dibatalkan.
///
/// ```dart
/// onPressed: () async {
///   if (!await ensureLoggedIn(context, ref)) return;
///   // ... aksi aslinya
/// }
/// ```
Future<bool> ensureLoggedIn(BuildContext context, WidgetRef ref) async {
  if (ref.read(authProvider).isAuthenticated) {
    return true;
  }

  await showLoginPromptSheet(context, ref);

  return false;
}

/// Sheet ajakan masuk untuk user yang belum login.
Future<void> showLoginPromptSheet(BuildContext context, WidgetRef ref) async {
  final language = ref.read(languageProvider);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon gembok di dalam lingkaran.
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                language == AppLanguage.english
                    ? 'Want to track this film?'
                    : 'Ingin mencatat film ini?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                language == AppLanguage.english
                    ? 'Sign in or create an account to save your watching '
                          'history, ratings, and reviews.'
                    : 'Silakan masuk atau daftar untuk menyimpan riwayat '
                          'tontonan, rating, dan ulasan Anda.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol utama.
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  child: Text(
                    language == AppLanguage.english
                        ? 'SIGN IN / SIGN UP'
                        : 'MASUK / DAFTAR',
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Tutup tanpa masuk.
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
                child: Text(
                  language == AppLanguage.english ? 'Not now' : 'Nanti Saja',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
