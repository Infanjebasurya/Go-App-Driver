import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

class VerificationProgressCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final int progressPercent;

  const VerificationProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hexFFE8EDF2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VERIFICATION PROGRESS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hexFF8FA0B0,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount of $totalCount documents verified',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.hexFF6B7C93,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progressPercent.toDouble()),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    '${value.round()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: AppColors.emerald,
                      letterSpacing: -1,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progressPercent / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 2,
                  backgroundColor: AppColors.hexFFE8EDF2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.emerald,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
