import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_placeholder.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/poster_image.dart';
import '../widgets/rating_stars.dart';
import '../widgets/transitions.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  bool _includeYours = true;
  bool _includeIncoming = true;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final res = await Navigator.of(context).push<List<bool>>(
      fadeSlideRoute<List<bool>>(
        ActivityFiltersPage(
          includeYours: _includeYours,
          includeIncoming: _includeIncoming,
        ),
      ),
    );
    if (res != null && mounted) {
      setState(() {
        _includeYours = res[0];
        _includeIncoming = res[1];
      });
    }
  }

  Widget _entries(List<ActivityEntry> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No activity yet', style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (var i = 0; i < items.length; i++)
          FadeInUp(index: i, child: _ActivityTile(entry: items[i])),
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 8, 4),
                    child: Row(
                      children: [
                        const Text(
                          'Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _openFilters,
                          icon: const Icon(Icons.filter_list, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabs,
                    indicatorColor: AppColors.green,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.muted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Friends'),
                      Tab(text: 'You'),
                      Tab(text: 'Incoming'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<ActivityEntry>>(
              valueListenable: AppState.activities,
              builder: (context, mine, _) {
                final friends = <ActivityEntry>[
                  if (_includeYours) ...mine,
                  if (_includeIncoming) ...DummyData.incoming,
                ]..sort((a, b) => b.watchedOn.compareTo(a.watchedOn));
                return TabBarView(
                  controller: _tabs,
                  children: [
                    _entries(friends),
                    _entries(mine),
                    _entries(DummyData.incoming),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityEntry entry;
  const _ActivityTile({required this.entry});

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                      '${e.user} watched',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      _ago(e.watchedOn),
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: e.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' ${e.year}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingStars(rating: e.rating.round()),
                    if (e.liked) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.favorite, size: 15, color: AppColors.orange),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PosterImage(width: 56, height: 84, url: e.posterUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.review,
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityFiltersPage extends StatefulWidget {
  final bool includeYours;
  final bool includeIncoming;

  const ActivityFiltersPage({
    super.key,
    required this.includeYours,
    required this.includeIncoming,
  });

  @override
  State<ActivityFiltersPage> createState() => _ActivityFiltersPageState();
}

class _ActivityFiltersPageState extends State<ActivityFiltersPage> {
  late bool _yours = widget.includeYours;
  late bool _incoming = widget.includeIncoming;

  @override
  Widget build(BuildContext context) {
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
          'Activity Filters',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(<bool>[_yours, _incoming]),
          ),
        ],
      ),
      body: Column(
        children: [
          CheckboxListTile(
            value: _yours,
            onChanged: (v) => setState(() => _yours = v ?? false),
            activeColor: AppColors.navBg,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.trailing,
            title: const Text(
              'Include your activity',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
          CheckboxListTile(
            value: _incoming,
            onChanged: (v) => setState(() => _incoming = v ?? false),
            activeColor: AppColors.navBg,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.trailing,
            title: const Text(
              'Include incoming activity',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
        ],
      ),
    );
  }
}
