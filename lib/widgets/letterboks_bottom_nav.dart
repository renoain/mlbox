import 'package:flutter/material.dart';

/// Bottom navigation: Films, Search, Add, Activity, Profile
class LetterboksBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const LetterboksBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const Color _bg = Color(0xFF445566);
  static const Color _active = Color(0xFF40BCF4);
  static const Color _inactive = Color(0xFFB8C4D0);
  static const Color _add = Color(0xFF00C853);

  static const List<IconData> _icons = [
    Icons.crop_portrait_rounded, // Films (ganti SVG kalau mau persis)
    Icons.search_rounded,
    Icons.add_circle_outline_rounded, // Add
    Icons.bolt_outlined, // Activity
    Icons.person_outline_rounded, // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (i) {
              final isAdd = i == 2;
              final color = isAdd
                  ? _add
                  : (i == currentIndex ? _active : _inactive);
              return IconButton(
                onPressed: onTap == null ? null : () => onTap!(i),
                icon: Icon(_icons[i], color: color, size: isAdd ? 32 : 26),
              );
            }),
          ),
        ),
      ),
    );
  }
}
