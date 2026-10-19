import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama Letterboxd
  static const Color background = Color(0xFF14181C);
  static const Color surface = Color(0xFF1C252E);
  static const Color primary = Color(0xFF00E054);

  // Warna Teks & Elemen Lain
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9AB5C4);
  static const Color error = Color(0xFFFF4C4C);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      // Warna dasar aplikasi
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        error: error,
      ),

      // Pengaturan AppBar (Bagian atas)
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Pengaturan Tombol Utama (Hijau)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black, // Teks tombol hitam
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Pengaturan Kolom Input (Email, Password, Search)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Pengaturan Teks Default
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }
}
