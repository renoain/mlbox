import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/result_cards.dart';
import '../widgets/transitions.dart';
import 'rate_page.dart';

/// Tombol (+): cari film -> pilih -> halaman rating.
class AddFilmPage extends StatefulWidget {
  const AddFilmPage({super.key});

  @override
  State<AddFilmPage> createState() => _AddFilmPageState();
}

class _AddFilmPageState extends State<AddFilmPage> {
  final TextEditingController _c = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _pick(FilmItem film) {
    AppState.addRecent(_q);
    Navigator.of(context).push(fadeSlideRoute<void>(RatePage(film: film)));
  }

  void _useRecent(String r) {
    _c.text = r;
    _c.selection = TextSelection.collapsed(offset: r.length);
    setState(() => _q = r);
  }

  Widget _body() {
    if (_q.trim().isEmpty) {
      return ValueListenableBuilder<List<String>>(
        valueListenable: AppState.recentSearches,
        builder: (context, items, _) => ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'RECENT SEARCHES',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (final r in items)
              InkWell(
                onTap: () => _useRecent(r),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    r,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    final results = DummyData.searchFilms(_q);
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No films found for "$_q"',
          style: const TextStyle(color: AppColors.muted),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (var i = 0; i < results.length; i++)
          FadeInUp(
            index: i,
            child: FilmResultTile(film: results[i], onTap: () => _pick(results[i])),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.header,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.navBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _c,
                          autofocus: true,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'Add a film',
                            hintStyle: TextStyle(color: AppColors.textSoft),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          onChanged: (v) => setState(() => _q = v),
                          onSubmitted: AppState.addRecent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }
}
