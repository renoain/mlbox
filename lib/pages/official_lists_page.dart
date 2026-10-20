import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bars.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/poster_strip.dart';
import '../widgets/transitions.dart';
import 'list_detail_page.dart';

class OfficialListsPage extends StatelessWidget {
  const OfficialListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lists = DummyData.officialLists;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: blackAppBar(
        'Official Lists',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (var i = 0; i < lists.length; i++)
            FadeInUp(
              index: i,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  fadeSlideRoute<void>(ListDetailPage(list: lists[i])),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lists[i].title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${lists[i].filmCount} films',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const PosterStrip(count: 8),
                      const SizedBox(height: 10),
                      Text(
                        lists[i].description,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
