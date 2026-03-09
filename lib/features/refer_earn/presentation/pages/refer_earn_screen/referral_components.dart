import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';

import '../../../domain/entities/referral.dart';

PreferredSizeWidget buildReferEarnAppBar(BuildContext context, String title) {
  return AppAppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leading: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Icon(
          Icons.arrow_back_ios,
          color: AppColors.headingDark,
          size: 14,
        ),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.headingDark,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: AppColors.strokeLight, height: 1),
    ),
  );
}

class CampaignRow extends StatelessWidget {
  const CampaignRow({super.key, required this.campaign, required this.onTap});

  final ReferralCampaign campaign;
  final VoidCallback onTap;

  IconData get _icon {
    switch (campaign.type) {
      case CampaignType.bike:
        return Icons.two_wheeler;
      case CampaignType.auto:
        return Icons.electric_rickshaw;
      case CampaignType.cab:
        return Icons.local_taxi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceF5,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: AppColors.neutral444, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                campaign.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.headingDark,
                ),
              ),
            ),
            Text(
              '= ₹${campaign.reward}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: AppColors.headingDark,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class InviteButton extends StatelessWidget {
  const InviteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: SizedBox(
        height: 54,
        child: ShadowButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AuthUiColors.brandGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Text(
            'Invite Riders',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          label: const Icon(Icons.arrow_forward, size: 18),
        ),
      ),
    );
  }
}

class StatCol extends StatelessWidget {
  const StatCol({
    super.key,
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  final String value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: highlighted ? AppColors.headingDark : AppColors.headingDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralAAA,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
