import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import 'poster_image.dart';

/// Empat slot poster film favorit, ala Letterboxd.
///
/// Setiap slot bisa berisi poster atau kosong. Poster bisa dihapus lewat
/// tombol X di pojoknya, dan posternya bisa digeser (tahan lalu geser) untuk
/// mengubah urutan. Slot kosong membuka pemilih film.
class FavoritePosters extends StatelessWidget {
  /// Isi tiap slot. `null` berarti slot kosong.
  final List<Movie?> slots;

  /// Warna garis pemisah di atas dan bawah.
  final Color lineColor;

  /// Warna kotak poster kosong.
  final Color placeholderColor;

  /// Warna ikon di kotak poster kosong.
  final Color iconColor;

  /// Dipanggil saat slot kosong diklik.
  final VoidCallback? onAdd;

  /// Dipanggil saat tombol hapus di poster diklik.
  final ValueChanged<Movie>? onRemove;

  /// Dipanggil saat urutan slot berubah (index lama, index baru).
  final void Function(int oldIndex, int newIndex)? onReorder;

  const FavoritePosters({
    super.key,
    this.slots = const [],
    this.lineColor = const Color(0xFF3B4A5A),
    this.placeholderColor = const Color(0xFF667788),
    this.iconColor = const Color(0xFFC8D3DD),
    this.onAdd,
    this.onRemove,
    this.onReorder,
  });

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: lineColor),
          bottom: BorderSide(color: lineColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width =
              (constraints.maxWidth - _gap * (slots.length - 1)) / slots.length;

          // Viewport horizontal butuh tinggi yang pasti; di dalam ListView
          // vertikal tingginya unbounded, jadi tinggi dihitung dari lebar slot.
          return SizedBox(
            height: width * 3 / 2,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Handle drag dibuat manual supaya slot kosong tidak bisa digeser.
              buildDefaultDragHandles: false,
              itemCount: slots.length,
              // `onReorderItem` sudah meng-adjust newIndex sendiri, jadi
              // tidak perlu pengurangan manual seperti di `onReorder`.
              onReorderItem: onReorder ?? (_, _) {},
              itemBuilder: (context, index) {
                final Movie? movie = slots[index];

                return SizedBox(
                  key: ValueKey(
                    movie != null ? 'movie-${movie.id}' : 'empty-$index',
                  ),
                  width: width,
                  child: movie != null
                      ? _filledSlot(context, index, movie)
                      : _emptySlot(context),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _filledSlot(BuildContext context, int index, Movie movie) {
    final Widget poster = Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => context.push('/movie/${movie.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: PosterImage(url: movie.posterUrl, fit: BoxFit.cover),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onRemove!(movie),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xCC000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ),
      ],
    );

    return AspectRatio(
      aspectRatio: 2 / 3,
      child: onReorder == null
          ? poster
          : ReorderableDelayedDragStartListener(index: index, child: poster),
    );
  }

  Widget _emptySlot(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Material(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onAdd,
          child: Icon(Icons.add, color: iconColor, size: 28),
        ),
      ),
    );
  }
}
