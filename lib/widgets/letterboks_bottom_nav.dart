import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';

/// Bottom nav 2 mode:
///  - guest (3): Account, Films, Search
///  - member (5): Films, Search, Add (+), Activity, Profile
class LetterboksBottomNav extends StatelessWidget {
  final bool loggedIn;
  final AppTab selected;
  final ValueChanged<AppTab> onTap;

  const LetterboksBottomNav({
    super.key,
    required this.loggedIn,
    required this.selected,
    required this.onTap,
  });

  static const List<AppTab> _guestTabs = [
    AppTab.account,
    AppTab.films,
    AppTab.search,
  ];
  static const List<AppTab> _memberTabs = [
    AppTab.films,
    AppTab.search,
    AppTab.add,
    AppTab.activity,
    AppTab.profile,
  ];

  static List<AppTab> tabsFor(bool loggedIn) =>
      loggedIn ? _memberTabs : _guestTabs;

  static const Map<AppTab, IconData> _icons = {
    AppTab.account: Icons.account_circle_outlined,
    AppTab.films: Icons.crop_portrait_rounded,
    AppTab.search: Icons.search_rounded,
    AppTab.add: Icons.add_circle_outline_rounded,
    AppTab.activity: Icons.bolt_outlined,
    AppTab.profile: Icons.person_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navBg,
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _NavContent(
            key: ValueKey<bool>(loggedIn),
            tabs: tabsFor(loggedIn),
            selected: selected,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _NavContent extends StatelessWidget {
  final List<AppTab> tabs;
  final AppTab selected;
  final ValueChanged<AppTab> onTap;

  const _NavContent({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final n = tabs.length;
          final index = tabs.indexOf(selected);
          const pillWidth = 64.0;
          double alignX = 0;
          if (index >= 0) {
            final center = (index + 0.5) / n * w;
            alignX = (((center - pillWidth / 2) / (w - pillWidth)) * 2 - 1)
                .clamp(-1.0, 1.0)
                .toDouble();
          }
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedAlign(
                  alignment: Alignment(alignX, 0),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: index >= 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: pillWidth,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.navPill,
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final t in tabs)
                    Expanded(
                      child: _NavButton(
                        tab: t,
                        selected: t == selected,
                        onTap: () => onTap(t),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isAdd = widget.tab == AppTab.add;
    final color = isAdd
        ? AppColors.green
        : (widget.selected ? AppColors.blue : AppColors.navIcon);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Center(
        child: AnimatedScale(
          scale: _pressed ? 0.8 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Icon(
            LetterboksBottomNav._icons[widget.tab],
            color: color,
            size: isAdd ? 32 : 26,
          ),
        ),
      ),
    );
  }
}
