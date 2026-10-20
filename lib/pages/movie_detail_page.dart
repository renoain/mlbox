import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/movie.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/rating_stars.dart';

class MovieDetailPage extends ConsumerWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: movieAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (movie) {
          return CustomScrollView(
            slivers: [
              // Backdrop & Judul
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: AppTheme.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      movie.posterUrl != null
                          ? Image.network(movie.posterUrl!, fit: BoxFit.cover)
                          : Container(color: AppTheme.surface),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppTheme.background, Colors.transparent],
                            stops: [0.0, 0.6],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${movie.releaseDate ?? ""} • ${movie.runtime ?? 0} mins',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: movie.posterUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(movie.posterUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: AppTheme.surface,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Konten
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating Section
                      _RatingSection(movie: movie),
                      const SizedBox(height: 20),

                      // Tombol Watchlist & Watched
                      _LibraryActions(movieId: movie.id),
                      const SizedBox(height: 24),

                      // Sinopsis
                      Text(
                        movie.overview ?? 'Tidak ada sinopsis.',
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Tulis Review
                      OutlinedButton.icon(
                        onPressed: () {
                          if (!ref.read(authProvider).isAuthenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Masuk dulu untuk menulis review.',
                                ),
                                action: SnackBarAction(
                                  label: 'Masuk',
                                  onPressed: () => context.push('/login'),
                                ),
                              ),
                            );
                            return;
                          }
                          // Pindah ke form review, bawa ID film
                          context.push('/movie/${movie.id}/review');
                        },
                        icon: const Icon(Icons.edit, color: AppTheme.primary),
                        label: const Text(
                          'TULIS REVIEW',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Cast
                      const Text(
                        'CAST',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCastRow('Christian Bale', 'Patrick Bateman'),
                      _buildCastRow('Justin Theroux', 'Timothy Bryce'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCastRow(String name, String character) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                character,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LibraryActions extends ConsumerStatefulWidget {
  final int movieId;
  const _LibraryActions({required this.movieId});

  @override
  ConsumerState<_LibraryActions> createState() => _LibraryActionsState();
}

class _LibraryActionsState extends ConsumerState<_LibraryActions> {
  bool _busy = false;

  bool get _isLoggedIn => ref.read(authProvider).isAuthenticated;

  void _requireLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Masuk dulu untuk memakai fitur ini.'),
        action: SnackBarAction(
          label: 'Masuk',
          onPressed: () => context.push('/login'),
        ),
      ),
    );
  }

  Future<void> _toggleWatchlist(bool currentlyIn) async {
    if (!_isLoggedIn) {
      _requireLogin();
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(watchlistRepositoryProvider);
      if (currentlyIn) {
        await repo.remove(widget.movieId);
      } else {
        await repo.add(widget.movieId);
      }
      ref.invalidate(watchlistProvider);
      if (mounted) {
        _showMessage(
          currentlyIn ? 'Dihapus dari watchlist.' : 'Ditambahkan ke watchlist.',
        );
      }
    } catch (e) {
      if (mounted) _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleWatched(bool currentlyWatched) async {
    if (!_isLoggedIn) {
      _requireLogin();
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(watchedRepositoryProvider);
      if (currentlyWatched) {
        await repo.unwatch(widget.movieId);
      } else {
        await repo.markWatched(widget.movieId);
        // Backend otomatis mengeluarkan film dari watchlist.
        ref.invalidate(watchlistProvider);
      }
      ref.invalidate(watchedProvider);
      if (mounted) {
        _showMessage(
          currentlyWatched
              ? 'Dibatalkan dari watched.'
              : 'Ditandai sudah ditonton.',
        );
      }
    } catch (e) {
      if (mounted) _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logFilm() async {
    if (!_isLoggedIn) {
      _requireLogin();
      return;
    }

    final result = await showDialog<_LogFilmData>(
      context: context,
      builder: (context) => const _LogFilmDialog(),
    );

    if (result == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(diaryRepositoryProvider);
      await repo.createDiary(
        movieId: widget.movieId,
        watchedDate: result.watchedDate,
        note: result.note,
      );
      // Backend otomatis mengeluarkan film dari watchlist saat di-log.
      ref.invalidate(diaryProvider);
      ref.invalidate(watchlistProvider);
      if (mounted) _showMessage('Film masuk ke log.');
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inWatchlist = ref.watch(isInWatchlistProvider(widget.movieId));
    final isWatched = ref.watch(isWatchedProvider(widget.movieId));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _busy ? null : () => _toggleWatchlist(inWatchlist),
                icon: Icon(inWatchlist ? Icons.check : Icons.add, size: 18),
                label: Text(inWatchlist ? 'IN WATCHLIST' : 'WATCHLIST'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _busy ? null : () => _toggleWatched(isWatched),
                icon: Icon(isWatched ? Icons.check : Icons.done, size: 18),
                label: Text(isWatched ? 'WATCHED' : 'MARK WATCHED'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B444F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : _logFilm,
          icon: const Icon(Icons.calendar_today, size: 18),
          label: const Text('LOG FILM'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}

class _LogFilmData {
  final String? watchedDate;
  final String? note;

  _LogFilmData({this.watchedDate, this.note});
}

class _LogFilmDialog extends StatefulWidget {
  const _LogFilmDialog();

  @override
  State<_LogFilmDialog> createState() => _LogFilmDialogState();
}

class _LogFilmDialogState extends State<_LogFilmDialog> {
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_date.year.toString().padLeft(4, '0')}-'
      '${_date.month.toString().padLeft(2, '0')}-'
      '${_date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: const Text('Log Film', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanggal tonton',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(_formattedDate),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              minimumSize: const Size(0, 44),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Catatan (opsional)',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Tulis catatan singkat...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('BATAL'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(
            _LogFilmData(
              watchedDate: _formattedDate,
              note: _noteController.text,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.black,
            minimumSize: const Size(0, 44),
          ),
          child: const Text('SIMPAN'),
        ),
      ],
    );
  }
}

class _RatingSection extends ConsumerStatefulWidget {
  final Movie movie;

  const _RatingSection({required this.movie});

  @override
  ConsumerState<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends ConsumerState<_RatingSection> {
  int _myRating = 0;
  bool _busy = false;

  bool get _isLoggedIn => ref.read(authProvider).isAuthenticated;

  void _requireLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Masuk dulu untuk memberi rating.'),
        action: SnackBarAction(
          label: 'Masuk',
          onPressed: () => context.push('/login'),
        ),
      ),
    );
  }

  Future<void> _rate(int value) async {
    if (!_isLoggedIn) {
      _requireLogin();
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(movieRepositoryProvider);
      final saved = await repo.rateMovie(widget.movie.id, value);
      ref.invalidate(movieDetailProvider(widget.movie.id));
      if (mounted) {
        setState(() => _myRating = saved);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating $saved bintang disimpan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final average = widget.movie.averageRating ?? 0;
    final count = widget.movie.reviewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'RATINGS',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 16),
            if (count > 0 || average > 0) ...[
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              RatingStars(rating: average.round(), size: 16),
              const SizedBox(width: 8),
              Text(
                '($count)',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ] else
              const Text(
                'Belum ada rating',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Rating kamu',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(width: 12),
            if (_busy)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              )
            else
              RatingStars(
                rating: _myRating,
                size: 28,
                isInteractive: true,
                onRatingChanged: _rate,
              ),
          ],
        ),
      ],
    );
  }
}
