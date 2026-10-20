import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../repositories/diary_repository.dart';
import 'poster_image.dart';

/// Daftar log/diary ala Letterboxd.
///
/// Setiap tanggal punya kepala bulan (mis. "OCTOBER 2026"), lalu isinya
/// ditampilkan sebagai baris: kotak tanggal di kiri, poster kecil, judul
/// film, dan tahun rilisnya di kanan.
class DiaryList extends StatelessWidget {
  final List<DiaryDay> days;

  /// Dipanggil saat baris ditekan. Kalau null, baris membuka halaman film.
  final ValueChanged<DiaryEntry>? onTap;

  const DiaryList({super.key, required this.days, this.onTap});

  static const List<String> _monthsLong = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  static const List<String> _monthsShort = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, color: Colors.white38, size: 52),
              SizedBox(height: 16),
              Text(
                'Log masih kosong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Film yang kamu catat akan muncul di sini, dikelompokkan per tanggal.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Ratakan kepala bulan dan baris film jadi satu daftar supaya bisa
    // digulir sebagai satu kesatuan.
    final List<Widget> children = [];
    for (final DiaryDay day in days) {
      final DateTime? date = DateTime.tryParse(day.watchedDate);
      if (date != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: Text(
              '${_monthsLong[date.month - 1]} ${date.year}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ),
        );
      }

      for (final DiaryEntry entry in day.items) {
        children.add(_DiaryRow(entry: entry, date: date, onTap: onTap));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }
}

class _DiaryRow extends StatelessWidget {
  final DiaryEntry entry;
  final DateTime? date;
  final ValueChanged<DiaryEntry>? onTap;

  const _DiaryRow({required this.entry, required this.date, this.onTap});

  @override
  Widget build(BuildContext context) {
    final movie = entry.movie;
    final String year = movie.releaseDate?.split('-').first ?? '';

    // Salin ke variabel lokal supaya nullable-nya bisa dipromosikan.
    final DateTime? when = date;
    final String dayNumber = when == null ? '' : '${when.day}';
    final String monthName = when == null
        ? ''
        : DiaryList._monthsShort[when.month - 1];

    return InkWell(
      onTap: onTap == null
          ? () => context.push('/movie/${movie.id}')
          : () => onTap!(entry),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kotak tanggal
            Container(
              width: 46,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    dayNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    monthName,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Poster kecil
            Container(
              width: 40,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: PosterImage(url: movie.posterUrl, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),

            // Judul + catatan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (year.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                year,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
