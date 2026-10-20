import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../models/movie.dart';
import '../models/review.dart';
import '../providers/library_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/lists_tab.dart';
import '../widgets/login_prompt.dart';
import '../widgets/poster_image.dart';
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
                      PosterImage(
                        url: movie.backdropUrl ?? movie.posterUrl,
                        fit: BoxFit.cover,
                        placeholder: Container(color: AppTheme.surface),
                      ),
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
                                  const SizedBox(height: 6),
                                  _AverageRating(movie: movie),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: AppTheme.surface,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: PosterImage(
                                  url: movie.posterUrl,
                                  fit: BoxFit.cover,
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

                      // Tombol Like + Tulis Review
                      Row(
                        children: [
                          _LikeButton(movie: movie),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                if (!await ensureLoggedIn(context, ref)) {
                                  return;
                                }
                                if (!context.mounted) return;
                                // Pindah ke form review, bawa ID film
                                context.push('/movie/${movie.id}/review');
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: AppTheme.primary,
                              ),
                              label: const Text(
                                'TULIS REVIEW',
                                style: TextStyle(color: AppTheme.primary),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                                side: const BorderSide(color: AppTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Cast
                      if (movie.cast.isNotEmpty) ...[
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
                        ...movie.cast.map(_buildCastRow),
                      ],

                      // Crew
                      if (movie.crew != null &&
                          movie.crew!.trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'CREW',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          movie.crew!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],

                      // Review dari semua user
                      const SizedBox(height: 28),
                      _ReviewsSection(movieId: movie.id),
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

  Widget _buildCastRow(String name) {
    final String trimmed = name.trim();
    final String initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.surface,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ringkasan rating rata-rata film, ditampilkan di dekat judul.
class _AverageRating extends StatelessWidget {
  final Movie movie;

  const _AverageRating({required this.movie});

  @override
  Widget build(BuildContext context) {
    final double average = movie.averageRating ?? 0;
    final int count = movie.reviewCount;

    if (count == 0) {
      return const Text(
        'Belum ada rating',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      );
    }

    return Row(
      children: [
        RatingStars(rating: average.round(), size: 14),
        const SizedBox(width: 6),
        Text(
          average.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Daftar review dari semua user untuk sebuah film.
class _ReviewsSection extends ConsumerWidget {
  final int movieId;

  const _ReviewsSection({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(movieReviewsProvider(movieId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REVIEWS',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        reviewsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal memuat review: ${error.toString().replaceFirst('Exception: ', '')}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(movieReviewsProvider(movieId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada review untuk film ini.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              );
            }

            return Column(
              children: [
                for (final Review review in reviews)
                  _ReviewTile(review: review),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Satu baris review: avatar, nama user, bintang, tanggal, dan teksnya.
class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String get _formattedDate {
    final DateTime? parsed = DateTime.tryParse(review.createdAt);
    if (parsed == null) return '';

    return '${parsed.day} ${_months[parsed.month - 1]} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final String name = review.userName.trim();
    final String initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.surface,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name.isEmpty ? 'Anonymous' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_formattedDate.isNotEmpty)
                Text(
                  _formattedDate,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          if (review.rating > 0) ...[
            const SizedBox(height: 8),
            RatingStars(rating: review.rating, size: 13),
          ],
          if (review.content.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tombol hati untuk menandai film sebagai "disuka".
///
/// Statusnya di-update secara optimistik: ikon langsung berubah begitu
/// diklik, lalu dikembalikan ke semula kalau API-nya gagal.
class _LikeButton extends ConsumerStatefulWidget {
  final Movie movie;

  const _LikeButton({required this.movie});

  @override
  ConsumerState<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<_LikeButton> {
  late bool _isLiked;
  late int _count;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.movie.isLiked;
    _count = widget.movie.likeCount;
  }

  @override
  void didUpdateWidget(covariant _LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Selaraskan dengan data terbaru dari server, kecuali sedang ada
    // permintaan yang sedang berjalan.
    if (_busy) return;

    if (oldWidget.movie.isLiked != widget.movie.isLiked ||
        oldWidget.movie.likeCount != widget.movie.likeCount) {
      setState(() {
        _isLiked = widget.movie.isLiked;
        _count = widget.movie.likeCount;
      });
    }
  }

  Future<void> _toggle() async {
    if (_busy) return;

    // Guest diarahkan ke sheet ajakan masuk lebih dulu.
    if (!await ensureLoggedIn(context, ref)) {
      return;
    }

    // Update tampilan duluan, baru kirim ke server.
    setState(() {
      _busy = true;
      _isLiked = !_isLiked;
      _count += _isLiked ? 1 : -1;
    });

    try {
      final repo = ref.read(movieRepositoryProvider);
      if (_isLiked) {
        await repo.likeMovie(widget.movie.id);
      } else {
        await repo.unlikeMovie(widget.movie.id);
      }

      // Daftar likes ikut berubah.
      ref.invalidate(likedMoviesProvider);
    } catch (e) {
      // Kembalikan ke kondisi semula.
      setState(() {
        _isLiked = !_isLiked;
        _count += _isLiked ? 1 : -1;
      });

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
    final Color color = _isLiked ? AppTheme.error : AppTheme.textSecondary;

    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: color,
              size: 22,
            ),
            if (_count > 0) ...[
              const SizedBox(width: 6),
              Text(
                '$_count',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
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

  /// Guest diarahkan ke sheet ajakan masuk.
  Future<bool> _requireLogin() async {
    return ensureLoggedIn(context, ref);
  }

  Future<void> _toggleWatchlist(bool currentlyIn) async {
    if (!await _requireLogin()) {
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
    if (!await _requireLogin()) {
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
      // Menandai watched juga membuat entri log, jadi halaman Log perlu
      // disegarkan supaya film langsung terlihat di sana.
      ref.invalidate(diaryProvider);
      if (mounted) {
        _showMessage(
          currentlyWatched
              ? 'Dibatalkan dari watched.'
              : 'Ditandai sudah ditonton dan masuk ke log.',
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
    if (!await _requireLogin()) {
      return;
    }
    if (!mounted) return;

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
      // Mencatat ke log juga menandai film sebagai watched.
      ref.invalidate(watchedProvider);
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
                  // Hijau kalau film sudah ditonton, abu-abu kalau belum.
                  backgroundColor: isWatched
                      ? AppTheme.primary
                      : const Color(0xFF3B444F),
                  foregroundColor: isWatched ? Colors.black : Colors.white,
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // "Log Film" dan "Tambah ke List" sebaris, supaya tinggi halaman
        // tidak bertambah dan tombol Tulis Review tetap kelihatan.
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _logFilm,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('LOG FILM'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _openAddToList(context, ref),
                icon: const Icon(Icons.playlist_add, size: 18),
                label: const Text(
                  'Tambah ke List',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  minimumSize: const Size(0, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Buka sheet untuk memilih list tujuan film ini.
  Future<void> _openAddToList(BuildContext context, WidgetRef ref) async {
    if (!await ensureLoggedIn(context, ref)) {
      return;
    }
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetContext) => _AddToListSheet(movieId: widget.movieId),
    );
  }
}

/// Bottom sheet untuk menambahkan film ke salah satu list milik user.
class _AddToListSheet extends ConsumerWidget {
  final int movieId;

  const _AddToListSheet({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Tambah ke List',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: listsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.white54,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.invalidate(listsProvider),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
              data: (lists) {
                if (lists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.list_alt_outlined,
                          color: Colors.white38,
                          size: 44,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum ada list',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Buat list dulu, baru tambahkan film ke dalamnya.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => showCreateListDialog(context, ref),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Buat List Baru'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.list_alt_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        list.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${list.itemCount} film',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                      onTap: () =>
                          _addToList(context, ref, list.id, list.title),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToList(
    BuildContext context,
    WidgetRef ref,
    int listId,
    String listTitle,
  ) async {
    try {
      await ref.read(listRepositoryProvider).addItemToList(listId, movieId);

      if (!context.mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Film ditambahkan ke "$listTitle".')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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

  /// Guest diarahkan ke sheet ajakan masuk.
  Future<bool> _requireLogin() async {
    return ensureLoggedIn(context, ref);
  }

  Future<void> _rate(int value) async {
    if (!await _requireLogin()) {
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
        // Rata-rata dari semua user sudah tampil di dekat judul, jadi di sini
        // cukup star rating milik user yang sedang login.
        Row(
          children: [
            const Text(
              'RATING KAMU',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
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
            const SizedBox(width: 12),
            if (count > 0)
              Text(
                'Rata-rata $average dari $count review',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
