import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/lb_widgets.dart';

/// Tour pengenalan aplikasi: 5 halaman penjelasan + 1 halaman penutup.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _steps = [
    _Step(
      'Use $kAppName to track the films you\u2019ve watched, and those you want to watch',
      'assets/images/onboarding_1.png',
    ),
    _Step(
      'Log and rate each film as you watch it, to build up a diary of your viewing history',
      'assets/images/onboarding_2.png',
    ),
    _Step(
      'Add a review and tags to each entry, then share and discuss with others',
      'assets/images/onboarding_3.png',
    ),
    _Step(
      'Follow your friends to see what they\u2019re watching and liking in your activity feed',
      'assets/images/onboarding_4.png',
    ),
    _Step(
      'Make lists, find cast and crew info, see what\u2019s popular in your network, and more!',
      'assets/images/onboarding_5.png',
    ),
  ];

  final _controller = PageController();
  int _index = 0;

  int get _pageCount => _steps.length + 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LbColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pageCount,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              if (i < _steps.length) return _StepPage(step: _steps[i]);
              return const _FinalPage();
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28 + MediaQuery.of(context).padding.bottom,
            child: _Dots(count: _pageCount, index: _index),
          ),
        ],
      ),
    );
  }
}

class _Step {
  const _Step(this.caption, this.image);
  final String caption;
  final String image;
}

/// Halaman 1-5: gradasi di atas, teks penjelasan, lalu cuplikan tampilan app.
class _StepPage extends StatelessWidget {
  const _StepPage({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF445565), LbColors.background],
          stops: [0.0, 0.17],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: top + 44),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              step.caption,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE6EBF0),
                fontSize: 18,
                height: 1.4,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  step.image,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

/// Halaman 6: foto latar, logo, tombol Sign in / Create account / Skip.
class _FinalPage extends StatelessWidget {
  const _FinalPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final heroH = box.maxHeight * 0.52;
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/onboarding_6_hero.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00181B20), LbColors.background],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Column(
                  children: [
                    SizedBox(height: heroH - 20),
                    const LbLogo(
                      diameter: 60,
                      stepFactor: 0.94,
                      lensColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      kAppName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The social network for film lovers.',
                      style: TextStyle(color: LbColors.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 26),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          _PanelButton(
                            height: 108,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _PanelText(
                                  'Sign in',
                                  onTap: () => context.push('/login'),
                                ),
                                _PanelText(
                                  'Create account',
                                  onTap: () => context.push('/register'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _PanelButton(
                            height: 56,
                            child: _PanelText(
                              'Skip this step',
                              onTap: () => context.go('/home'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'An account is not required to browse content, but '
                            'you must have one to track films and participate.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: LbColors.muted,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({required this.height, required this.child});
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF445566),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

class _PanelText extends StatelessWidget {
  const _PanelText(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFE6EBF0), fontSize: 17),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index ? const Color(0xFF8D9EB0) : const Color(0xFF3A4654),
            ),
          ),
      ],
    );
  }
}
