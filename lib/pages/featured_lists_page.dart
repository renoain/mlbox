import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bars.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/poster_strip.dart';
import '../widgets/transitions.dart';
import 'list_detail_page.dart';

class FeaturedListsPage extends StatelessWidget {
  const FeaturedListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lists = DummyData.featuredLists;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: blackAppBar('Featured Lists'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Letterboks Community',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lists[i].title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const PosterStrip(count: 8),
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
