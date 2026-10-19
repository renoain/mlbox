import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('bami9'), // Dummy username
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.textSecondary),
            onPressed: () => context.push('/settings'), // Navigasi ke Settings
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Avatar & Nama ---
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.surface,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'bami9',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bergabung sejak Okt 2026',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Baris Statistik (Dummy) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Films', '12'),
                  _buildStatItem('Following', '5'),
                  _buildStatItem('Followers', '8'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- 4 Favourite Films ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'FAVOURITE FILMS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140, // Tinggi poster favorit
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4, // Selalu 4 slot
                itemBuilder: (context, index) {
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      // Nanti ganti dengan Image.network dari API
                    ),
                    child: const Center(
                      child: Icon(Icons.movie, color: AppTheme.textSecondary),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // --- Tab Section (Films, Diary, Reviews, dll) ---
            const Divider(color: AppTheme.surface, thickness: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem('Films', isActive: true),
                  _buildTabItem('Diary'),
                  _buildTabItem('Reviews'),
                  _buildTabItem('Lists'),
                ],
              ),
            ),
            const Divider(color: AppTheme.surface, thickness: 2),

            // --- Isi Tab (Dummy) ---
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'Daftar film yang ditonton akan muncul di sini',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, {bool isActive = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        if (isActive)
          Container(
            height: 2,
            width: 20,
            color: AppTheme.primary, // Garis Hijau
          ),
      ],
    );
  }
}