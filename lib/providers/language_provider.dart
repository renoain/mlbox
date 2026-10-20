import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_language.dart';

/// Kunci penyimpanan preferensi bahasa.
const _languageKey = 'app_language';

/// Bahasa yang sedang dipakai aplikasi.
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((
  ref,
) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.indonesia) {
    _load();
  }

  /// Baca bahasa yang tersimpan sebelumnya.
  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? code = prefs.getString(_languageKey);
      if (code != null && mounted) {
        state = AppLanguage.fromCode(code);
      }
    } catch (_) {
      // Kalau preferensi tidak bisa dibaca, pakai bahasa bawaan.
    }
  }

  /// Simpan dan pakai bahasa baru.
  Future<void> setLanguage(AppLanguage language) async {
    state = language;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
    } catch (_) {
      // Preferensi gagal disimpan, tapi bahasa di sesi ini tetap terpakai.
    }
  }
}
