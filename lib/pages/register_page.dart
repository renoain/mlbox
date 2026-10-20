import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/lb_widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _acceptTerms = false;
  bool _acceptPrivacy = false;

  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      setState(() => _error = 'Semua kolom wajib diisi.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password minimal 8 karakter.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Konfirmasi password tidak sama.');
      return;
    }
    if (!_acceptTerms || !_acceptPrivacy) {
      setState(
        () => _error =
            'Kamu harus menyetujui Terms of Use dan Privacy Policy dulu.',
      );
      return;
    }

    setState(() => _error = null);

    final ok = await ref
        .read(authProvider.notifier)
        .register(name, email, password);

    if (!mounted) return;

    if (ok) {
      context.go('/home');
    } else {
      setState(
        () =>
            _error = ref.read(authProvider).errorMessage ?? 'Registrasi gagal.',
      );
    }
  }

  /// Tombol X: kembali ke halaman sebelumnya, atau ke Home kalau tidak ada.
  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w700);

    final auth = ref.watch(authProvider);
    final bool isLoading = auth.isLoading;

    return AuthShell(
      heroAsset: 'assets/images/auth_register_hero.png',
      heroFraction: 0.54,
      title: 'Join MLBox',
      onClose: _close,
      fields: [
        AuthField(
          hint: 'Email address',
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        AuthField(
          hint: 'Username',
          controller: _nameController,
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
        ),
        AuthField(
          hint: 'Password',
          obscure: true,
          controller: _passwordController,
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
        ),
        AuthField(
          hint: 'Confirm password',
          obscure: true,
          controller: _confirmController,
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        AuthConsentRow(
          value: _acceptTerms,
          onChanged: (v) => setState(() => _acceptTerms = v),
          child: const Text.rich(
            TextSpan(
              text: "I'm at least 16 years old and accept the ",
              children: [TextSpan(text: 'Terms of Use', style: bold)],
            ),
          ),
        ),
        AuthConsentRow(
          value: _acceptPrivacy,
          showDivider: false,
          onChanged: (v) => setState(() => _acceptPrivacy = v),
          child: const Text.rich(
            TextSpan(
              text: 'I accept the ',
              children: [
                TextSpan(text: 'Privacy Policy', style: bold),
                TextSpan(
                  text:
                      ' and consent to the processing of my personal '
                      'information in accordance with it',
                ),
              ],
            ),
          ),
        ),
        if (_error != null) AuthError(_error!),
      ],
      buttons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LbOutlineButton(
            label: 'SIGN IN',
            onPressed: isLoading ? null : _close,
          ),
          const SizedBox(width: 10),
          LbOutlineButton(
            label: 'RESET PASSWORD',
            onPressed: isLoading
                ? null
                : () => _showMessage('Fitur belum tersedia.'),
          ),
          const SizedBox(width: 10),
          LbGreenButton(
            label: 'JOIN',
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
      credit: const AuthCredit(film: 'Onward'),
    );
  }
}
