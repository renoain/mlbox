import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/lb_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(fontWeight: FontWeight.w700);
    return AuthShell(
      heroAsset: 'assets/images/auth_register_hero.png',
      heroFraction: 0.54,
      title: 'Join MLBox',
      onClose: () => context.pop(),
      fields: [
        const AuthField(
          hint: 'Email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const AuthField(hint: 'Username'),
        const AuthField(hint: 'Password', obscure: true),
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
      ],
      buttons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LbOutlineButton(label: 'SIGN IN', onPressed: () => context.pop()),
          const SizedBox(width: 10),
          LbOutlineButton(label: 'RESET PASSWORD', onPressed: () {}),
          const SizedBox(width: 10),
          LbGreenButton(
            label: 'JOIN',
            // Nanti Lead yang akan menyambungkan ini ke API
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      credit: const AuthCredit(film: 'Onward'),
    );
  }
}
