import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/half_star_rating.dart';
import '../widgets/poster_image.dart';
import '../widgets/transitions.dart';
import 'add_tags_page.dart';
import 'edit_text_page.dart';

/// Halaman "I Watched": tanggal, rating, like, review, tags, toggle.
class RatePage extends StatefulWidget {
  final FilmItem film;
  const RatePage({super.key, required this.film});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  static const List<String> _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  DateTime? _date = DateTime.now();
  double _rating = 0;
  bool _liked = false;
  String _review = '';
  String _tags = '';
  bool _firstWatch = false;
  bool _noSpoilers = false;

  String _formatDate(DateTime d) =>
      '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _save() {
    AppState.addActivity(
      ActivityEntry(
        title: widget.film.title,
        year: widget.film.year,
        rating: _rating,
        liked: _liked,
        review: _review,
        posterUrl: widget.film.posterUrl,
        watchedOn: _date ?? DateTime.now(),
      ),
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
    AppState.goTo(AppTab.activity);
  }

  Widget _line() => const Divider(height: 1, color: AppColors.divider);

  @override
  Widget build(BuildContext context) {
    final f = widget.film;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'I Watched',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Film
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  PosterImage(width: 34, height: 50, url: f.posterUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _line(),
            // Tanggal
            InkWell(
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                    const Spacer(),
                    Text(
                      _date == null ? 'No date' : _formatDate(_date!),
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _date = null),
                      icon: const Icon(Icons.cancel, color: AppColors.navBg),
                    ),
                  ],
                ),
              ),
            ),
            _line(),
            // Rating + like
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HalfStarRating(
                        value: _rating,
                        onChanged: (v) => setState(() => _rating = v),
                      ),
                      const SizedBox(height: 2),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          'Rate',
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _liked = !_liked),
                    child: Column(
                      children: [
                        AnimatedScale(
                          scale: _liked ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            Icons.favorite,
                            size: 38,
                            color: _liked ? AppColors.orange : AppColors.starOff,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Like',
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Review
            Expanded(
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  fadeSlideRoute<void>(
                    EditTextPage(
                      initial: _review,
                      onChanged: (v) => setState(() => _review = v),
                    ),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _review.isEmpty ? 'Add review\u2026' : _review,
                    style: TextStyle(
                      color: _review.isEmpty ? AppColors.muted : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            _line(),
            // Tags
            InkWell(
              onTap: () => Navigator.of(context).push(
                fadeSlideRoute<void>(
                  AddTagsPage(
                    initial: _tags,
                    onChanged: (v) => setState(() => _tags = v),
                  ),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  _tags.isEmpty ? 'Add tags\u2026' : _tags,
                  style: TextStyle(
                    color: _tags.isEmpty ? AppColors.muted : Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            _line(),
            // Toggle
            Row(
              children: [
                Expanded(
                  child: _Toggle(
                    icon: Icons.visibility_outlined,
                    label: 'First-time watch',
                    on: _firstWatch,
                    onTap: () => setState(() => _firstWatch = !_firstWatch),
                  ),
                ),
                Expanded(
                  child: _Toggle(
                    icon: Icons.visibility_off_outlined,
                    label: 'No spoilers',
                    on: _noSpoilers,
                    onTap: () => setState(() => _noSpoilers = !_noSpoilers),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  const _Toggle({
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = on ? Colors.white : AppColors.starOff;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(color: color, fontSize: 12),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(icon, key: ValueKey<bool>(on), color: color, size: 34),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
