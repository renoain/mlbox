import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'fade_in_up.dart';

/// Tiga lingkaran logo (oranye, hijau, biru).
class LogoDots extends StatelessWidget {
  final double size;
  const LogoDots({super.key, this.size = 28});

  Widget _dot(Color c, double left) => Positioned(
        left: left,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final offset = size * 0.77;
    return SizedBox(
      width: size + offset * 2,
      height: size,
      child: Stack(
        children: [
          _dot(AppColors.orange, 0),
          _dot(const Color(0xFF00E054), offset),
          _dot(AppColors.blue, offset * 2),
        ],
      ),
    );
  }
}

/// Bagian atas halaman login/join: artwork (placeholder gradient),
/// tombol X, logo, dan judul.
/// TODO: ganti gradient dengan Image.asset artwork dari desain.
class AuthHero extends StatelessWidget {
  final String title;
  const AuthHero({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1BA8C4), Color(0xFF6A3BA0), Color(0xFF2B1E5C)],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00191C21), Color(0xFF191C21)],
              stops: [0.55, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: FadeInUp(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoDots(),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
