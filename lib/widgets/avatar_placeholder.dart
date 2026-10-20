import 'package:flutter/material.dart';

/// Placeholder avatar pengguna (bulat/persegi dengan ikon orang).
///
/// Dibuat sebagai adaptor untuk file UI stage 4 yang sebelumnya memakai
/// parameter `radius` dan `icon` pada `PosterImage`, sedangkan versi
/// `PosterImage` di project ini hanya menerima `url/width/height`.
class AvatarPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final IconData icon;
  final Color? background;

  const AvatarPlaceholder({
    super.key,
    this.width = 32,
    this.height = 32,
    this.radius = 16,
    this.icon = Icons.person_rounded,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: background ?? const Color(0xFF2B3744),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: Colors.white38, size: height * 0.55),
    );
  }
}
