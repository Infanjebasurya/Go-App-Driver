import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../navigation/onboarding_route_transitions.dart';
import '../theme/onboarding_ui_tokens.dart';
import '../widgets/onboarding_flow_scope.dart';
import '../widgets/onboarding_common.dart';
import 'drive_earn_onboarding_page.dart';
import 'package:goapp/core/theme/app_colors.dart';

class CabAutoOnboardingPage extends StatelessWidget {
  const CabAutoOnboardingPage({super.key});

  static const Color _yellow = AppColors.hexFFF8C84A;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final compact = height < 700;
              final tight = height < 640;
              final topPad = tight ? 8.0 : 12.0;
              final subtitleSize = tight ? 12.5 : (compact ? 13.0 : 14.0);
              final sectionHeight = height * (8 / 13);
              final imageWidthByScreen =
                  screenWidth * (tight ? 0.72 : (compact ? 0.78 : 0.85));
              final imageWidthByHeight =
                  sectionHeight * (tight ? 1.05 : (compact ? 1.12 : 1.2));
              // ignore: unused_local_variable
              final imageWidth = math.min(
                imageWidthByScreen,
                imageWidthByHeight,
              );
              final bottomPad = tight ? 18.0 : 24.0;
              final spaceLarge = tight ? 20.0 : 28.0;
              final spaceMid = tight ? 10.0 : 14.0;
              final spaceDots = tight ? 18.0 : 28.0;

              return Column(
                children: [
                  OnboardingSkipButton(
                    onTap: () => OnboardingFlowScope.finishToLogin(context),
                    topPadding: topPad,
                    textColor: AppColors.hex99111217,
                  ),
                  Expanded(
                    flex: 8,
                    child: LayoutBuilder(
                      builder: (context, area) {
                        // ignore: unused_local_variable
                        final imageHeight = math.min(
                          area.maxHeight * (tight ? 0.74 : 0.82),
                          area.maxHeight,
                        );
                        return ClipRect(
                          child: Stack(
                            children: [
                              Center(
                                child: Transform.translate(
                                  offset: const Offset(0, 10),
                                  child: Image.asset(
                                    'assets/image/screen3.png',
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.94,
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
                        SizedBox(height: spaceLarge),
                        Text(
                          'Upload Document',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: OnboardingUiColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: spaceMid),
                        OnboardingSubtitle(
                          text:
                              'Uploaded documents are securely stored and\nreviewed to verify driver eligibility.',
                          fontSize: subtitleSize,
                          maxLines: 2,
                          maxWidth: 340,
                          horizontalPadding: 24,
                        ),
                        SizedBox(height: spaceDots),
                        const OnboardingPageDots(activeIndex: 1),
                        const Spacer(),
                        OnboardingNavigationRow(
                          onBack: () => Navigator.pop(context),
                          onNext: () {
                            final nextPage = OnboardingFlowScope.wrapNext(
                              context,
                              const ParcelDeliveryOnboardingPage(),
                            );
                            Navigator.of(
                              context,
                            ).push(onboardingCabToParcelRoute(nextPage));
                          },
                          bottomPadding: bottomPad,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _CurvedYellowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CabAutoOnboardingPage._yellow
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.18);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height * 0.08,
      size.width * 0.52,
      size.height * 0.12,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.16,
      size.width,
      size.height * 0.12,
    );
    path.lineTo(size.width, size.height * 0.74);
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.84,
      size.width * 0.52,
      size.height * 0.78,
    );
    path.quadraticBezierTo(
      size.width * 0.24,
      size.height * 0.72,
      0,
      size.height * 0.78,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
