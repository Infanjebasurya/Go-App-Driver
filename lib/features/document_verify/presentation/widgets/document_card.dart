import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

import '../model/document_model.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;

  const DocumentCard({super.key, required this.document, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: document.isUploading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: document.isCompleted
                ? AppColors.emerald.withValues(alpha: 0.3)
                : const Color(0xFFE8EDF2),
            width: document.isCompleted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              _DocumentIcon(document: document),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.headingNavy,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(document: document),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentIcon extends StatelessWidget {
  final Document document;

  const _DocumentIcon({required this.document});

  IconData get _icon {
    switch (document.type) {
      case DocumentType.drivingLicense:
        return Icons.credit_card_rounded;
      case DocumentType.vehicleRC:
        return Icons.directions_car_rounded;
      case DocumentType.aadhaarCard:
        return Icons.fingerprint_rounded;
      case DocumentType.panCard:
        return Icons.receipt_long_rounded;
      case DocumentType.bankDetails:
        return Icons.account_balance_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = document.isCompleted
        ? AppColors.emerald
        : const Color(0xFF8FA0B0);

    return SizedBox(
      width: 42,
      height: 42,
      child: Icon(_icon, color: color, size: 22),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Document document;

  const _StatusBadge({required this.document});

  @override
  Widget build(BuildContext context) {
    if (document.isUploading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
        ),
      );
    }

    if (document.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.emerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 13, color: AppColors.emerald),
            SizedBox(width: 4),
            Text(
              'COMPLETED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.emerald,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.coolwhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5DDE5)),
      ),
      child: const Text(
        'REQUIRED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8FA0B0),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
