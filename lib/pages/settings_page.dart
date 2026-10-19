import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // Kembali ke profil
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Account'),
          _buildListTile(context, Icons.person_outline, 'Edit Profile'),
          _buildListTile(context, Icons.lock_outline, 'Change Password'),

          const Divider(color: AppTheme.surface),

          _buildSectionHeader('Preferences'),
          _buildListTile(
            context,
            Icons.language,
            'Language',
            trailing: 'English',
          ),
          _buildListTile(context, Icons.dark_mode, 'Theme', trailing: 'Dark'),

          const Divider(color: AppTheme.surface),

          _buildSectionHeader('About'),
          _buildListTile(
            context,
            Icons.info_outline,
            'About MLBox',
            trailing: 'v1.0.0',
          ),
          _buildListTile(context, Icons.help_outline, 'Help & Support'),

          const SizedBox(height: 30),

          // Tombol Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface, // Tombol abu-abu gelap
                foregroundColor: AppTheme.error, // Teks merah
              ),
              onPressed: () {
                // Nanti teman Logic (Anda/Orang 1) yang mengurus fungsi logout
                context.go('/home');
              },
              child: const Text('LOG OUT'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title, {
    String? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: trailing != null
          ? Text(
              trailing,
              style: const TextStyle(color: AppTheme.textSecondary),
            )
          : const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () {
        // Aksi klik nanti
      },
    );
  }
}
