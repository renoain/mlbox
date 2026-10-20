import 'package:flutter/material.dart';

/// Item muncul fade + naik tipis. Makin besar index, makin lambat
/// (efek staggered tanpa package tambahan).
class FadeInUp extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeInUp({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final step = index > 8 ? 8 : index;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + step * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}
