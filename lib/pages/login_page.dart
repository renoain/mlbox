import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // Kembali ke Home
        ),
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(decoration: InputDecoration(hintText: 'Email')),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // Tombol ini belum memanggil API, nanti kita sambungkan
              onPressed: () {
                // Karena ini fase desain, kita langsung lempar ke home saja
                context.go('/home');
              },
              child: const Text('LOG IN'),
            ),
          ],
        ),
      ),
    );
  }
}
