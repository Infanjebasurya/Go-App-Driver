import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: AppColors.headingNavy,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Step ${currentStep + 1} to $totalSteps',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emerald,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 28),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(totalSteps, (i) {
              final isCompleted = i < currentStep;
              final isCurrent = i == currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  height: 3.5,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.emerald
                        : AppColors.hexFFE2E8F0,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
