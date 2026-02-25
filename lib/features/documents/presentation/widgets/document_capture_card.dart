import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

class DocumentCaptureCard extends StatelessWidget {
  final String label;
  final bool captured;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const DocumentCaptureCard({
    super.key,
    required this.label,
    required this.captured,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: captured ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: captured
                ? AppColors.emerald.withValues(alpha: 0.35)
                : const Color(0xFFE2E8F0),
            width: captured ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: captured
                        ? Container(
                            key: const ValueKey('captured'),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.emerald,
                              size: 26,
                            ),
                          )
                        : Container(
                            key: const ValueKey('empty'),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.coolwhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.smartphone_rounded,
                              color: Color(0xFFB0BEC5),
                              size: 26,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: captured
                          ? AppColors.emerald
                          : const Color(0xFF6B7C93),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    captured ? 'Captured' : 'Tap to Capture',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: captured
                          ? AppColors.emerald.withValues(alpha: 0.7)
                          : AppColors.emerald,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            if (captured && onRemove != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
