import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

class UnderlineInputField extends StatelessWidget {
  final String label;
  final String hint;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? suffixText;
  final FocusNode? focusNode;

  const UnderlineInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.suffixText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: hasError ? const Color(0xFFE53935) : const Color(0xFF8FA0B0),
            letterSpacing: 0.2,
          ),
        ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1A2236),
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: readOnly
                ? const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF8FA0B0),
                    size: 22,
                  )
                : null,
            suffixText: suffixText,
            errorText: errorText,
            errorStyle: const TextStyle(
              fontSize: 11,
              color: Color(0xFFE53935),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFE53935) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFE53935) : AppColors.emerald,
                width: 1.8,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE53935), width: 1.2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE53935), width: 1.8),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }
}
