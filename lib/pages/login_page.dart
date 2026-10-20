import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/lb_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi.');
      return;
    }

    setState(() => _error = null);

    final ok = await ref.read(authProvider.notifier).login(email, password);

    if (!mounted) return;

    if (ok) {
      context.go('/home');
    } else {
      setState(
        () => _error = ref.read(authProvider).errorMessage ?? 'Login gagal.',
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
    final auth = ref.watch(authProvider);
    final bool isLoading = auth.isLoading;

    return AuthShell(
      heroAsset: 'assets/images/auth_login_hero.png',
      heroFraction: 0.68,
      title: 'Sign in to MLBox',
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
          hint: 'Password',
          obscure: true,
          controller: _passwordController,
          enabled: !isLoading,
          showDivider: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        if (_error != null) AuthError(_error!),
      ],
      buttons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LbOutlineButton(
            label: 'JOIN',
            onPressed: isLoading ? null : () => context.push('/register'),
          ),
          const SizedBox(width: 10),
          LbOutlineButton(
            label: 'RESET PASSWORD',
            onPressed: isLoading
                ? null
                : () => _showMessage('Fitur belum tersedia.'),
          ),
          const SizedBox(width: 10),
          LbGreenButton(label: 'GO', isLoading: isLoading, onPressed: _submit),
        ],
      ),
      credit: const AuthCredit(film: 'Coraline'),
    );
  }
}
