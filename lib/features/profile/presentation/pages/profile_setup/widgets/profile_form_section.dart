import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/app_text_field.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_state.dart';

class ProfileFormSection extends StatelessWidget {
  const ProfileFormSection({
    super.key,
    required this.formState,
    required this.nameController,
    required this.emailController,
    required this.onNameChanged,
    required this.onEmailChanged,
  });

  final ProfileSetupState formState;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _lineField(
          label: 'Full Name',
          errorText: formState.showValidation ? formState.nameError : null,
          child: AppTextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
            ],
            label: '',
            hint: 'e.g., Yogesh S',
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
            onChanged: onNameChanged,
          ),
        ),
        const SizedBox(height: 20),
        _lineField(
          label: 'Email',
          errorText: formState.showValidation ? formState.emailError : null,
          child: AppTextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            label: '',
            hint: 'e.g., name@example.com',
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
            onChanged: onEmailChanged,
          ),
        ),
      ],
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
