import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/dummy_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/result_cards.dart';
import '../widgets/transitions.dart';
import 'list_detail_page.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _labels = [
    'All',
    'Films',
    'Reviews',
    'Lists',
    'Cast, Crew or Studios',
  ];

  late final TabController _tabs =
      TabController(length: _labels.length, vsync: this);
  final TextEditingController _c = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _tabs.dispose();
    _c.dispose();
    super.dispose();
  }

  void _useRecent(String r) {
    _c.text = r;
    _c.selection = TextSelection.collapsed(offset: r.length);
    setState(() => _q = r);
  }

  void _openFilm(FilmItem f) {
    AppState.addRecent(_q);
    context.push('/movie/${f.id}');
  }

  void _openList(ListItem l) {
    AppState.addRecent(_q);
    Navigator.of(context).push(fadeSlideRoute<void>(ListDetailPage(list: l)));
  }

  Widget _empty() => Center(
        child: Text(
          'No results for "$_q"',
          style: const TextStyle(color: AppColors.muted),
        ),
      );

  Widget _list(List<Widget> items) {
    if (items.isEmpty) return _empty();
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (var i = 0; i < items.length; i++) FadeInUp(index: i, child: items[i]),
      ],
    );
  }

  Widget _all() {
    final films = DummyData.searchFilms(_q).take(3);
    final people = DummyData.searchPeople(_q).take(3);
    return _list([
      for (final f in films) FilmResultTile(film: f, onTap: () => _openFilm(f)),
      for (final p in people) PersonResultTile(person: p),
    ]);
  }

  Widget _films() => _list([
        for (final f in DummyData.searchFilms(_q))
          FilmResultTile(film: f, onTap: () => _openFilm(f)),
      ]);

  Widget _reviews() => _list([
        for (final r in DummyData.searchReviews(_q)) ReviewResultCard(review: r),
      ]);

  Widget _lists() => _list([
        for (final l in DummyData.searchLists(_q))
          ListResultCard(list: l, onTap: () => _openList(l)),
      ]);

  Widget _people() => _list([
        for (final p in DummyData.searchPeople(_q)) PersonResultTile(person: p),
      ]);

  Widget _recent() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: AppState.recentSearches,
      builder: (context, items, _) {
        return ListView(
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
        );
      },
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _c,
                            autofocus: true,
                            cursorColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(color: AppColors.muted),
                              border: InputBorder.none,
                            ),
                            onChanged: (v) => setState(() => _q = v),
                            onSubmitted: AppState.addRecent,
                          ),
                        ),
                        if (_q.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _c.clear();
                              setState(() => _q = '');
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    indicatorColor: AppColors.green,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.muted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    tabs: [for (final l in _labels) Tab(text: l)],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _q.trim().isEmpty
                ? _recent()
                : TabBarView(
                    controller: _tabs,
                    children: [_all(), _films(), _reviews(), _lists(), _people()],
                  ),
          ),
        ],
      ),
    );
  }
}
