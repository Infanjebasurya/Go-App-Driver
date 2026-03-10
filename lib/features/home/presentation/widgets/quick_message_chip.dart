import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class QuickMessageChip extends StatelessWidget {
  const QuickMessageChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceF0,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.neutral333,
            fontSize: 14 / 1.08,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}



