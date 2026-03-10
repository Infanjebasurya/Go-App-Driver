import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class ReferralRulesSection extends StatelessWidget {
  const ReferralRulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'How it Works',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.headingDark,
          ),
        ),
        SizedBox(height: 14),
        _HowItWorksStep(
          number: '1',
          title: 'Share your link',
          subtitle:
              'Send your unique invite link to professional\nbike riders in your network.',
        ),
        _HowItWorksStep(
          number: '2',
          title: 'Friend joins GoApp',
          subtitle:
              'Ensure they complete their registration using\nyour referral code.',
        ),
        _HowItWorksStep(
          number: '3',
          title: 'Friend completes 10 rides',
          subtitle:
              'Once they hit the milestone, the ₹3,000 reward\nis credited to your wallet.',
          isLast: true,
        ),
      ],
    );
  }
}

class ReferralSectionLabel extends StatelessWidget {
  const ReferralSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral888,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutralDDD, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral888,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(width: 1.5, height: 44, color: AppColors.strokeLight),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.headingDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral888,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: isLast ? 0 : 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
