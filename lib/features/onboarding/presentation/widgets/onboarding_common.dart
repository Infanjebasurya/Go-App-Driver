import 'package:flutter/material.dart';

import '../theme/onboarding_ui_tokens.dart';

class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({
    super.key,
    required this.onTap,
    this.topPadding = 12,
    this.textColor = OnboardingUiColors.textMuted,
    this.fontWeight = FontWeight.w500,
  });

  final VoidCallback onTap;
  final double topPadding;
  final Color textColor;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: topPadding, right: 20, bottom: 4),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          'Skip',
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({
    super.key,
    required this.activeIndex,
    this.total = 3,
    this.activeWidth = 24,
  });

  final int activeIndex;
  final int total;
  final double activeWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => Padding(
          padding: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
          child: Container(
            height: 6,
            width: index == activeIndex ? activeWidth : 6,
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? OnboardingUiColors.brandGreen
                  : OnboardingUiColors.dotInactive,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingNavigationRow extends StatelessWidget {
  const OnboardingNavigationRow({
    super.key,
    required this.onBack,
    required this.onNext,
    this.showBack = true,
    this.backIcon = Icons.arrow_back_ios,
    this.nextIcon = Icons.arrow_forward_ios,
    this.bottomPadding = 24,
    this.iconSize = 16,
    this.iconTextGap = 4,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool showBack;
  final IconData backIcon;
  final IconData nextIcon;
  final double bottomPadding;
  final double iconSize;
  final double iconTextGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            InkWell(
              onTap: onBack,
              child: Row(
                children: [
                  Icon(
                    backIcon,
                    size: iconSize,
                    color: OnboardingUiColors.textMuted,
                  ),
                  SizedBox(width: iconTextGap),
                  const Text(
                    'Back',
                    style: TextStyle(
                      color: OnboardingUiColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          InkWell(
            onTap: onNext,
            child: Row(
              children: [
                const Text(
                  'Next',
                  style: TextStyle(
                    color: OnboardingUiColors.brandGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: iconTextGap),
                Icon(
                  nextIcon,
                  size: iconSize,
                  color: OnboardingUiColors.brandGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
