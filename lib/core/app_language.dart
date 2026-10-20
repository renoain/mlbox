/// Bahasa yang bisa dipilih user di halaman Settings.
enum AppLanguage {
  indonesia('id', 'Indonesia'),
  english('en', 'English');

  const AppLanguage(this.code, this.label);

  /// Kode bahasa sesuai standar (mis. `id`, `en`).
  final String code;

  /// Nama bahasa yang ditampilkan di daftar pilihan.
  final String label;

  /// Ambil bahasa dari kode yang tersimpan, default ke Indonesia.
  static AppLanguage fromCode(String? code) {
    for (final AppLanguage language in AppLanguage.values) {
      if (language.code == code) return language;
    }

    return AppLanguage.indonesia;
  }
}
