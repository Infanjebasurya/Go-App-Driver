import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/app_text_field.dart';

class ProfileVehicleSection extends StatelessWidget {
  const ProfileVehicleSection({
    super.key,
    required this.referController,
    required this.onReferChanged,
  });

  final TextEditingController referController;
  final ValueChanged<String> onReferChanged;

  @override
  Widget build(BuildContext context) {
    return _lineField(
      label: 'Referral Code (optional)',
      child: AppTextField(
        controller: referController,
        label: '',
        hint: 'Enter code if applicable',
        borderless: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        hintStyle: const TextStyle(
          color: AppColors.inputHint,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        textStyle: const TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        onChanged: onReferChanged,
      ),
    );
  }
}

Widget _label(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 12.5,
      color: AppColors.black,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
  );
}

Widget _lineField({
  required String label,
  required Widget child,
  String? errorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      const SizedBox(height: 8),
      child,
      const SizedBox(height: 8),
      const Divider(height: 1, thickness: 1, color: AppColors.divider),
      if (errorText != null) ...[
        const SizedBox(height: 6),
        Text(
          errorText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.validationRed,
          ),
        ),
      ],
    ],
  );
}
