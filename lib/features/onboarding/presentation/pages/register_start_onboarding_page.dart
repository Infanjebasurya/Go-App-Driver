import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../navigation/onboarding_route_transitions.dart';
import '../theme/onboarding_ui_tokens.dart';
import '../widgets/onboarding_flow_scope.dart';
import '../widgets/onboarding_common.dart';
import 'upload_documents_onboarding_page.dart';
import 'package:goapp/core/theme/app_colors.dart';

class BikeTaxiOnboardingPage extends StatelessWidget {
  const BikeTaxiOnboardingPage({super.key});

  static const Color _blue = AppColors.hexFF0F4CB9;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              OnboardingSkipButton(
                onTap: () => OnboardingFlowScope.finishToLogin(context),
                fontWeight: FontWeight.w600,
              ),
              Expanded(
                flex: 8,
                child: LayoutBuilder(
                  builder: (context, area) {
                    final shortest = MediaQuery.of(context).size.shortestSide;
                    final isTablet = shortest >= 600;
                    // ignore: unused_local_variable
                    final imageWidth = area.maxWidth * (isTablet ? 0.54 : 0.68);
                    final imageHeightCap =
                        area.maxHeight * (isTablet ? 0.7 : 0.84);
                    // ignore: unused_local_variable
                    final imageHeight = math.min(
                      imageHeightCap,
                      area.maxHeight,
                    );
                    return ClipRect(
                      child: Stack(
                        children: [
                          Center(
                            child: Transform.translate(
                              offset: const Offset(0, 10),
                              child: Image.asset(
                                'assets/image/screen2.png',
                                width: MediaQuery.of(context).size.width * 0.94,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    const Text(
                      'Register and start drive',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: OnboardingUiColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const OnboardingSubtitle(
                      text:
                          'The registration process configures the drive\nmemory for safe and optimal operation.',
                      fontSize: 15,
                      maxLines: 2,
                      maxWidth: 340,
                      horizontalPadding: 24,
                    ),
                    const SizedBox(height: 22),
                    const OnboardingPageDots(activeIndex: 0, activeWidth: 28),
                    const Spacer(),
                    OnboardingNavigationRow(
                      onBack: () => Navigator.of(context).pop(),
                      onNext: () {
                        final nextPage = OnboardingFlowScope.wrapNext(
                          context,
                          const CabAutoOnboardingPage(),
                        );
                        Navigator.of(
                          context,
                        ).push(onboardingBikeToCabRoute(nextPage));
                      },
                      backIcon: Icons.arrow_back,
                      nextIcon: Icons.arrow_forward,
                      iconSize: 18,
                      iconTextGap: 8,
                      bottomPadding: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _DiagonalBluePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BikeTaxiOnboardingPage._blue
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.18)
      ..lineTo(size.width, size.height * 0.36)
      ..lineTo(size.width, size.height * 0.86)
      ..lineTo(0, size.height * 0.66)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
