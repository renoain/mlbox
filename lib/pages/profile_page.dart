import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/lb_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Data dummy, nanti diganti data dari API.
  static const _username = 'revachtrn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.profileBg,
      body: Column(
        children: [
          _Header(onSettings: () => context.push('/settings')),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 22),
                Center(
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2C3440),
                      border: Border.all(color: const Color(0xFF44546A), width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned(
                          bottom: -14,
                          child: Icon(Icons.person, size: 100, color: Color(0xFF556678)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const _Row(label: 'Activity', chevron: true, topLine: true),
                const SizedBox(height: 14),
                const _Row(label: 'Films', value: '0', topLine: true),
                const _Row(label: 'Diary', value: '0'),
                const _Row(label: 'Reviews', value: '0'),
                const _Row(label: 'Lists', value: '0', chevron: true),
                const _Row(label: 'Watchlist', value: '0', chevron: true),
                const _Row(label: 'Likes', value: '0'),
                const _Row(label: 'Tags', value: '0'),
                const _Row(label: 'Following', value: '0', chevron: true),
                const _Row(label: 'Followers', value: '0', chevron: true),
                const _Row(label: 'Stats', pro: true, bottomLine: true),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LbColors.appBarBlack,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: LbColors.rowLabel),
                  onPressed: onSettings,
                ),
                const Expanded(
                  child: Text(
                    ProfilePage._username,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: LbColors.rowLabel),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const _Segments(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments();

  @override
  Widget build(BuildContext context) {
    const items = ['Profile', 'Diary', 'Lists', 'Watchlist'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LbColors.segment,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == 0 ? LbColors.segmentActive : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    color: i == 0 ? Colors.white : LbColors.rowLabel,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    this.value,
    this.chevron = false,
    this.pro = false,
    this.topLine = false,
    this.bottomLine = false,
  });

  final String label;
  final String? value;
  final bool chevron;
  final bool pro;
  final bool topLine;
  final bool bottomLine;

  @override
  Widget build(BuildContext context) {
    const line = BorderSide(color: LbColors.divider, width: 1);
    return Container(
      height: 57,
      padding: const EdgeInsets.only(left: 28, right: 12),
      decoration: BoxDecoration(
        border: Border(
          top: topLine ? line : BorderSide.none,
          bottom: line,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: LbColors.rowLabel, fontSize: 18),
            ),
          ),
          if (pro) ...[
            const Text('Upgrade to ', style: TextStyle(color: LbColors.muted, fontSize: 15)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: LbColors.orange,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (value != null)
            Text(value!, style: const TextStyle(color: LbColors.muted, fontSize: 16)),
          if (chevron)
            const Icon(Icons.chevron_right, color: LbColors.rowLabel, size: 22)
          else if (value != null)
            const SizedBox(width: 22),
        ],
      ),
    );
  }
}
