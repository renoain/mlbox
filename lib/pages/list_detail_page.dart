import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bars.dart';
import '../widgets/avatar_placeholder.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/login_reminder.dart';
import '../widgets/poster_image.dart';

/// Detail list: tab Films (hero, info, like, tags, grid bernomor) + Comments.
class ListDetailPage extends StatefulWidget {
  final ListItem list;
  const ListDetailPage({super.key, required this.list});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  bool _liked = false;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Future<void> _toggleLike() async {
    final ok = await requireLogin(context, action: 'like lists');
    if (ok && mounted) setState(() => _liked = !_liked);
  }

  Widget _films() {
    final l = widget.list;
    final films = DummyData.rankedFilms(20);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const AspectRatio(
          aspectRatio: 16 / 9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B3744), Color(0xFF1D252C)],
              ),
            ),
            child: Center(
              child: Icon(Icons.movie_filter_rounded, color: Colors.white24, size: 48),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const AvatarPlaceholder(
                width: 24,
                height: 24,
                radius: 12,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.owner,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            l.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (l.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l.description,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleLike,
            child: Row(
              children: [
                AnimatedScale(
                  scale: _liked ? 1.25 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    Icons.favorite,
                    size: 20,
                    color: _liked ? AppColors.orange : AppColors.muted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _liked ? 'LIKED' : 'LIKE?',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_fmt(l.likes + (_liked ? 1 : 0))} likes',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (l.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in l.tags)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.54,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
            ),
            itemCount: films.length,
            itemBuilder: (context, i) => FadeInUp(
              index: i ~/ 4,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 2 / 3,
                    child: PosterImage(url: films[i].posterUrl),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${i + 1}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _comments() {
    final items = DummyData.comments;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (var i = 0; i < items.length; i++)
          FadeInUp(
            index: i,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AvatarPlaceholder(
                    width: 32,
                    height: 32,
                    radius: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              items[i].user,
                              style: const TextStyle(
                                color: AppColors.textSoft,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              items[i].ago,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].text,
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.list;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: blackAppBar(
        'List',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.green,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            const Tab(text: 'Films'),
            Tab(text: '${_fmt(l.commentsCount)} Comments'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [_films(), _comments()]),
    );
  }
}
