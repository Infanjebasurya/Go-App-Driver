import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';

import '../../../../../core/theme/app_colors.dart';

class ReferBanner extends StatelessWidget {
  const ReferBanner({super.key, required this.totalEarnings});

  final int totalEarnings;

  @override
  Widget build(BuildContext context) {
    final formatted = totalEarnings
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceFDF8,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.payments_sharp,
              color: AuthUiColors.brandGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL EARNINGS',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.neutralAAA,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '₹$formatted',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
