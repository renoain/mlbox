import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _notAvailable(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Fitur belum tersedia.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Account'),
          _buildListTile(
            context,
            Icons.person_outline,
            'Edit Profile',
            onTap: () => _notAvailable(context),
          ),
          _buildListTile(
            context,
            Icons.lock_outline,
            'Change Password',
            onTap: () => _notAvailable(context),
          ),

          const Divider(color: AppTheme.surface),

          _buildSectionHeader('Preferences'),
          _buildListTile(
            context,
            Icons.language,
            'Language',
            trailing: 'English',
            onTap: () => _notAvailable(context),
          ),
          _buildListTile(
            context,
            Icons.dark_mode,
            'Theme',
            trailing: 'Dark',
            onTap: () => _notAvailable(context),
          ),

          const Divider(color: AppTheme.surface),

          _buildSectionHeader('About'),
          _buildListTile(
            context,
            Icons.info_outline,
            'About MLBox',
            trailing: 'v1.0.0',
            onTap: () => _notAvailable(context),
          ),
          _buildListTile(
            context,
            Icons.help_outline,
            'Help & Support',
            onTap: () => _notAvailable(context),
          ),

          if (isLoggedIn) ...[
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surface,
                  foregroundColor: AppTheme.error,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text('LOG OUT'),
              ),
            ),
          ],
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
    VoidCallback? onTap,
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
      onTap: onTap,
    );
  }
}
