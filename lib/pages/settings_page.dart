import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/favorite_posters_section.dart';

/// Warna khusus halaman settings (diambil dari desain Letterboxd).
const _bg = Color(0xFF445566);
const _bgDark = Color(0xFF334455);
const _line = Color(0xFF3B4A5A);
const _label = Color(0xFFC8D3DD);
const _value = Color(0xFF8D9EB0);
const _section = Color(0xFF8D9EB0);
const _orange = Color(0xFFE8A03C);
const _poster = Color(0xFF667788);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _notAvailable(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Fitur belum tersedia.')));
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Container(
              color: _bg,
              child: Column(
                children: [
                  _TopBar(
                    onCancel: () => context.pop(),
                    onSave: () => _notAvailable(context),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Container(
                          color: _bgDark,
                          padding: const EdgeInsets.fromLTRB(28, 14, 20, 14),
                          child: Text.rich(
                            TextSpan(
                              text: 'Signed in as ',
                              style: const TextStyle(
                                color: _label,
                                fontSize: 17,
                              ),
                              children: [
                                TextSpan(
                                  text: user?.name ?? 'Tamu',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _Tile(
                          label: 'Password and authentication',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Sign out',
                          color: _orange,
                          onTap: () => _signOut(context, ref),
                        ),
                        const _Gap(),

                        const _SectionHeader('PROFILE'),
                        _Tile(
                          label: 'Email address',
                          value: user?.email ?? '-',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Given name',
                          onTap: () => _notAvailable(context),
                          noChevron: true,
                        ),
                        _Tile(
                          label: 'Family name',
                          onTap: () => _notAvailable(context),
                          noChevron: true,
                        ),
                        _Tile(
                          label: 'Location',
                          onTap: () => _notAvailable(context),
                          noChevron: true,
                        ),
                        _Tile(
                          label: 'Website',
                          onTap: () => _notAvailable(context),
                          noChevron: true,
                        ),
                        _Tile(
                          label: 'Bio',
                          onTap: () => _notAvailable(context),
                          noChevron: true,
                        ),
                        _Tile(
                          label: 'Pronoun',
                          value: 'They / their',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        const _Gap(),

                        const _SectionHeader('FAVORITE FILMS'),
                        const FavoritePostersSection(
                          lineColor: _line,
                          placeholderColor: _poster,
                          iconColor: _label,
                        ),
                        const _Gap(),

                        const _SectionHeader('AVATAR'),
                        const _AvatarRow(),
                        const _Gap(height: 50),

                        _Tile(
                          label: 'Custom posters',
                          value: 'Enabled',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Allow replies from',
                          value: 'Anyone',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'App icon',
                          value: 'Primary',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Push notifications',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Email notifications',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Subscription settings',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Advanced settings',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Siri Shortcuts',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Privacy policy',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Terms of use',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        const _Gap(height: 50),

                        const _SectionHeader('APP & ABOUT'),
                        _Tile(
                          label: 'Language',
                          value: 'English',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Dark mode',
                          value: 'System',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'About MLBox',
                          value: 'v1.0.0',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        _Tile(
                          label: 'Help & Support',
                          chevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        const _Gap(height: 50),

                        _Tile(
                          label: 'Send logs',
                          onTap: () => _notAvailable(context),
                          noChevron: true,
                        ),
                        _Tile(
                          label: 'Delete cache',
                          onTap: () => _notAvailable(context),
                          noChevron: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(28, 10, 20, 8),
                          child: Text(
                            'Removes any images that have been temporarily stored on this device.',
                            style: TextStyle(color: _value, fontSize: 13),
                          ),
                        ),
                        const _Gap(height: 40),

                        _Tile(
                          label: 'Deactivate account',
                          color: _orange,
                          noChevron: true,
                          onTap: () => _notAvailable(context),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onCancel, required this.onSave});
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: _value,
                  padding: const EdgeInsets.only(left: 28),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSave,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.only(right: 28),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 4, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: _section,
          fontSize: 12,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

/// Jarak antar grup, diberi garis tipis di atas dan bawah.
class _Gap extends StatelessWidget {
  const _Gap({this.height = 36});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _line)),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.onTap,
    this.value,
    this.chevron = false,
    this.noChevron = false,
    this.color = _label,
  });

  final String label;
  final VoidCallback onTap;
  final String? value;
  final bool chevron;
  final bool noChevron;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 57,
        padding: const EdgeInsets.only(left: 28, right: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(color: color, fontSize: 18)),
            ),
            if (value != null)
              Text(value!, style: const TextStyle(color: _value, fontSize: 15)),
            if (chevron && !noChevron)
              const Icon(Icons.chevron_right, color: _label, size: 22),
          ],
        ),
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow();

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(color: Colors.white);

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _line)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 14, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgDark,
              border: Border.all(color: const Color(0xFF5E6F82), width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: const Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: -14,
                  child: Icon(Icons.person, size: 96, color: Color(0xFF7A8BA0)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text.rich(
                TextSpan(
                  text: 'Add or update your avatar in ',
                  style: TextStyle(color: _value, fontSize: 14.5, height: 1.45),
                  children: [
                    TextSpan(text: 'Advanced Settings', style: link),
                    TextSpan(
                      text: '. If you connect a Twitter account or have a ',
                    ),
                    TextSpan(text: 'Gravatar', style: link),
                    TextSpan(
                      text:
                          ' with the same email as your Letterboxd account, '
                          'it may appear here.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
