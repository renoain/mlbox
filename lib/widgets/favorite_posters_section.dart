import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_theme.dart';
import '../models/movie.dart';
import '../providers/profile_provider.dart';
import 'favorite_posters.dart';
import 'movie_picker_sheet.dart';

/// Bagian "Film Favorit" yang bisa dipakai: tambah, hapus, dan ubah urutan.
///
/// Data disimpan lewat `PUT /api/favorites` (maksimal 4 film). Daftar lokal
/// dipakai sebagai working copy supaya tampilan responsif, lalu dikirim ke
/// server setiap kali ada perubahan.
class FavoritePostersSection extends ConsumerStatefulWidget {
  final Color lineColor;
  final Color placeholderColor;
  final Color iconColor;

  /// Jumlah slot yang tersedia.
  final int slots;

  const FavoritePostersSection({
    super.key,
    this.lineColor = const Color(0xFF3B4A5A),
    this.placeholderColor = const Color(0xFF667788),
    this.iconColor = const Color(0xFFC8D3DD),
    this.slots = 4,
  });

  @override
  ConsumerState<FavoritePostersSection> createState() =>
      _FavoritePostersSectionState();
}

class _FavoritePostersSectionState
    extends ConsumerState<FavoritePostersSection> {
  /// Working copy: empat slot, `null` berarti slot kosong.
  late List<Movie?> _slots;

  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _slots = List<Movie?>.filled(widget.slots, null);
    _syncFromProvider(notify: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dipanggil saat fase build, jadi isi langsung tanpa setState.
    _syncFromProvider(notify: false);
  }

  /// Mengisi slot dari data server selama user belum mengubah apa pun.
  void _syncFromProvider({bool notify = true}) {
    final List<Movie> favorites =
        ref.read(favoritesProvider).valueOrNull ?? const [];

    if (_dirty || favorites.isEmpty) return;

    final List<Movie?> slots = List<Movie?>.filled(widget.slots, null);
    for (var i = 0; i < favorites.length && i < slots.length; i++) {
      slots[i] = favorites[i];
    }

    if (!notify) {
      _slots = slots;
      return;
    }

    if (mounted) {
      setState(() => _slots = slots);
    } else {
      _slots = slots;
    }
  }

  Future<void> _pick() async {
    final Movie? picked = await showMoviePicker(
      context,
      title: 'Pilih film favorit',
    );
    if (picked == null || !mounted) return;

    // Film yang sama tidak boleh masuk dua kali.
    if (_slots.any((m) => m?.id == picked.id)) {
      _showMessage('Film itu sudah ada di daftar favorit.');
      return;
    }

    // Isi slot kosong pertama.
    final int emptyIndex = _slots.indexWhere((m) => m == null);
    if (emptyIndex == -1) {
      _showMessage('Maksimal ${widget.slots} film favorit.');
      return;
    }

    setState(() {
      _slots[emptyIndex] = picked;
      _dirty = true;
    });
    await _save();
  }

  Future<void> _remove(Movie movie) async {
    setState(() {
      final int index = _slots.indexWhere((m) => m?.id == movie.id);
      if (index != -1) _slots[index] = null;
      _dirty = true;
    });
    await _save();
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    setState(() {
      // `onReorderItem` sudah meng-adjust newIndex untuk item yang keluar.
      final Movie? moved = _slots.removeAt(oldIndex);
      _slots.insert(newIndex, moved);
      _dirty = true;
    });
    await _save();
  }

  Future<void> _save() async {
    final List<int> ids = _slots.whereType<Movie>().map((m) => m.id).toList();

    setState(() => _saving = true);

    try {
      await ref.read(favoriteRepositoryProvider).saveFavorites(ids);

      _dirty = false;
      ref.invalidate(favoritesProvider);

      if (mounted) {
        _showMessage(
          ids.isEmpty
              ? 'Daftar film favorit dikosongkan.'
              : 'Film favorit disimpan.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoritesProvider, (previous, next) {
      next.whenData((_) => _syncFromProvider());
    });

    final int filled = _slots.whereType<Movie>().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FavoritePosters(
          slots: _slots,
          lineColor: widget.lineColor,
          placeholderColor: widget.placeholderColor,
          iconColor: widget.iconColor,
          onAdd: _saving ? null : _pick,
          onRemove: _saving ? null : _remove,
          onReorder: _saving ? null : _reorder,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 10, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  filled == 0
                      ? 'Belum ada film favorit. Ketuk kotak + untuk memilih.'
                      : 'Tahan poster lalu geser untuk mengubah urutan.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (_saving)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
