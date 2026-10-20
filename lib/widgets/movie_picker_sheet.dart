import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import 'poster_image.dart';

/// Membuka sheet untuk memilih satu film dari katalog.
///
/// Dipakai untuk memilih film favorit dan untuk memilih film yang mau
/// direview lewat tombol Quick Review di navbar.
///
/// Mengembalikan film yang dipilih, atau null kalau sheet ditutup.
Future<Movie?> showMoviePicker(BuildContext context, {required String title}) {
  return showModalBottomSheet<Movie>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (context) => _MoviePickerSheet(title: title),
  );
}

class _MoviePickerSheet extends ConsumerStatefulWidget {
  final String title;

  const _MoviePickerSheet({required this.title});

  @override
  ConsumerState<_MoviePickerSheet> createState() => _MoviePickerSheetState();
}

class _MoviePickerSheetState extends ConsumerState<_MoviePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> _filter(List<Movie> movies) {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return movies;

    return movies
        .where(
          (m) =>
              m.title.toLowerCase().contains(q) ||
              (m.genres?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final moviesAsync = ref.watch(moviesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Gagang
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari judul film...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            Expanded(
              child: moviesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Gagal memuat daftar film: '
                      '${error.toString().replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                data: (movies) {
                  final List<Movie> results = _filter(movies);

                  if (results.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada film yang cocok.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final Movie movie = results[index];

                      return ListTile(
                        onTap: () => Navigator.of(context).pop(movie),
                        leading: Container(
                          width: 40,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: PosterImage(
                            url: movie.posterUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          [
                            if (movie.releaseDate != null)
                              movie.releaseDate!.split('-').first,
                            if (movie.genres != null &&
                                movie.genres!.isNotEmpty)
                              movie.genres,
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
