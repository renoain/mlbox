import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Movie Title'),
      ),
      body: const Center(
        child: Text(
          'Desain Poster & Review di sini',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
