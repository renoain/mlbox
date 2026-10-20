import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Konfigurasi alamat backend untuk seluruh aplikasi.
///
/// Android emulator tidak bisa menjangkau `127.0.0.1` milik host, jadi
/// memakai `10.0.2.2`. Platform lain (web/desktop) memakai `127.0.0.1`.
///
/// Alamat bisa dioverride saat menjalankan aplikasi, misalnya untuk HP
/// fisik yang memakai IP LAN:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
/// ```
class ApiConfig {
  const ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Host backend tanpa trailing slash, mis. `http://127.0.0.1:8000`.
  static String get host {
    if (_override.isNotEmpty) {
      return _override.replaceAll(RegExp(r'/+$'), '');
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Base URL API, mis. `http://127.0.0.1:8000/api`.
  static String get apiBaseUrl => '$host/api';

  /// Ubah nilai poster dari backend menjadi URL yang bisa dimuat perangkat.
  ///
  /// Menerima:
  /// - URL absolut (`http://127.0.0.1:8000/api/media/posters/x.jpg`)
  /// - Path absolut (`/api/media/posters/x.jpg`)
  /// - Path relatif (`posters/x.jpg`)
  ///
  /// URL absolut dari host lokal otomatis memakai host API yang aktif, supaya
  /// Android emulator memakai `10.0.2.2` dan bukan `127.0.0.1`.
  static String? resolveAssetUrl(dynamic value) {
    if (value == null) return null;

    final String raw = value.toString().trim();
    if (raw.isEmpty) return null;

    if (raw.startsWith('/')) {
      return '$host$raw';
    }

    final Uri? uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      // Path relatif tanpa slash, mis. `posters/film.jpg`. Backend menyimpannya
      // relatif terhadap `storage/app/public`, yang disajikan lewat
      // route `GET /api/media/{path}`.
      return '$host/api/media/$raw';
    }

    if (!_isLocalHost(uri.host)) {
      // URL eksternal (mis. TMDB) dibiarkan apa adanya.
      return uri.toString();
    }

    final Uri local = Uri.parse(host);
    final StringBuffer buffer = StringBuffer()
      ..write(local.scheme)
      ..write('://')
      ..write(local.host);
    if (local.hasPort) {
      buffer
        ..write(':')
        ..write(local.port);
    }
    buffer.write(uri.path);
    if (uri.hasQuery) {
      buffer
        ..write('?')
        ..write(uri.query);
    }
    return buffer.toString();
  }

  static bool _isLocalHost(String host) {
    final String h = host.toLowerCase();
    return h == '127.0.0.1' ||
        h == 'localhost' ||
        h == '0.0.0.0' ||
        h == '10.0.2.2';
  }
}
