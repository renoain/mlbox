import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/lb_widgets.dart';

/// Halaman "User" untuk pengguna yang belum login.
class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.background,
      body: LayoutBuilder(
        builder: (context, box) {
          final heroH = box.maxHeight * 0.52;
          return Stack(
            children: [
              // Artwork + gradasi ke warna latar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/user_hero.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00181B20), LbColors.background],
                          stops: [0.75, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Column(
                    children: [
                      SizedBox(height: heroH - 6),
                      const LbLogo(diameter: 48, stepFactor: 0.92),
                      const SizedBox(height: 14),
                      const Text(
                        kAppName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _MenuRow(
                        label: 'Sign in',
                        topLine: true,
                        onTap: () => context.push('/login'),
                      ),
                      _MenuRow(
                        label: 'Create account',
                        onTap: () => context.push('/register'),
                      ),
                      _MenuRow(
                        label: 'Open the tour',
                        onTap: () => context.push('/onboarding'),
                      ),
                      const SizedBox(height: 70),
                      const AuthCredit(film: 'Spiderman'),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.onTap, this.topLine = false});
  final String label;
  final VoidCallback onTap;
  final bool topLine;

  @override
  Widget build(BuildContext context) {
    const line = BorderSide(color: Color(0xFF2C3440), width: 1);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40,
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(top: topLine ? line : BorderSide.none, bottom: line),
        ),
        child: Text(
          label,
          style: const TextStyle(color: LbColors.rowLabel, fontSize: 15),
        ),
      ),
    );
  }
}
