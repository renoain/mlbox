import 'package:flutter/material.dart';

/// Segmented tab: Films | Reviews | Lists | Journal
class HomeTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const HomeTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const Color _container = Color(0xFF1F262E);
  static const Color _selected = Color(0xFF445566);
  static const Color _inactiveText = Color(0xFF94A3B8);
  static const Color _divider = Color(0xFF3A4654);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final isSelected = i == selectedIndex;
      children.add(
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _selected : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : _inactiveText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
      if (i < labels.length - 1) {
        final hideDivider = i == selectedIndex || i + 1 == selectedIndex;
        children.add(
          Container(
            width: 1,
            height: 14,
            color: hideDivider ? Colors.transparent : _divider,
          ),
        );
      }
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _container,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: children),
    );
  }
}
