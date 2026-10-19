import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('MLBox Home'),
        actions: [
          // Tombol ke halaman Login (Karena nanti butuh auth)
          IconButton(
            icon: const Icon(Icons.login, color: AppTheme.primary),
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Halaman Home', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            // Tombol dummy untuk tes masuk ke Detail Film
            ElevatedButton(
              onPressed: () => context.push('/movie/1'),
              child: const Text('Lihat Detail Film (Dummy)'),
            ),
          ],
        ),
      ),
    );
  }
}
