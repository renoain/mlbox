import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/lb_widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      heroAsset: 'assets/images/auth_login_hero.png',
      heroFraction: 0.68,
      title: 'Sign in to MLBox',
      onClose: () => context.pop(),
      fields: const [
        AuthField(hint: 'Username'),
        AuthField(hint: 'Password', obscure: true, showDivider: false),
      ],
      buttons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LbOutlineButton(
            label: 'JOIN',
            onPressed: () => context.push('/register'),
          ),
          const SizedBox(width: 10),
          LbOutlineButton(label: 'RESET PASSWORD', onPressed: () {}),
          const SizedBox(width: 10),
          LbGreenButton(
            label: 'GO',
            // Nanti Lead yang akan menyambungkan ini ke API
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      credit: const AuthCredit(film: 'Coraline'),
    );
  }
}
