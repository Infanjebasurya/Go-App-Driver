import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';

import '../../../../../core/theme/app_colors.dart';

class ReferralCodeWidget extends StatelessWidget {
  const ReferralCodeWidget({
    super.key,
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  final String code;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: Row(
        children: [
          Text(
            code,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppColors.headingDark,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              onCopy();
            },
            icon: Icon(
              copied ? Icons.check : Icons.copy,
              size: 16,
              color: AuthUiColors.brandGreen,
            ),
            label: Text(
              copied ? 'Copied!' : 'Copy',
              style: const TextStyle(
                color: AuthUiColors.brandGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
