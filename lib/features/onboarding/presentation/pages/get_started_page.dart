import 'package:flutter/material.dart';
import '../theme/onboarding_ui_tokens.dart';
import '../widgets/onboarding_primary_button.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  bool _prefetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefetched) return;
    _prefetched = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await precacheImage(const AssetImage('assets/image/screen1.png'), context);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      await precacheImage(const AssetImage('assets/image/screen2.png'), context);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      await precacheImage(const AssetImage('assets/image/screen3.png'), context);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      await precacheImage(const AssetImage('assets/image/screen4.png'), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'GoApp',
              style: TextStyle(
                fontSize: 72 / 2,
                fontWeight: FontWeight.w800,
                color: OnboardingUiColors.brandGreen,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: Colors.white)),
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, 10),
                      child: Image.asset(
                        'assets/image/screen1.png',
                        width: MediaQuery.of(context).size.width * 0.98,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 180);
                        },
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                              stops: [0.0, 0.619],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 48,
                    right: 48,
                    bottom: 10,
                    child: IgnorePointer(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xB3FFFFFF),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: OnboardingUiColors.textDark,
                      ),
                      children: [
                        TextSpan(text: 'Your '),
                        TextSpan(
                          text: 'journey ',
                          style: TextStyle(
                            color: OnboardingUiColors.brandGreen,
                          ),
                        ),
                        TextSpan(text: 'to '),
                        TextSpan(
                          text: 'smart\nearning ',
                          style: TextStyle(
                            color: OnboardingUiColors.brandGreen,
                          ),
                        ),
                        TextSpan(
                          text: 'begins here. ',
                          style: TextStyle(
                            color: OnboardingUiColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OnboardingPrimaryButton(
                    height: 50,
                    label: "Let's Get Started",
                    onPressed: widget.onGetStarted,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: widget.onSignIn,
                      child: const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: OnboardingUiColors.textMuted,
                          ),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: OnboardingUiColors.brandGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
