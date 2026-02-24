import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

class DocNumberField extends StatelessWidget {
  final String label;
  final String hint;
  final String? example;
  final String? errorText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? allowedPattern;
  final bool forceUppercase;

  const DocNumberField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.allowedPattern,
    this.forceUppercase = false,
    this.example,
    this.errorText,
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
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          textCapitalization:
              forceUppercase ? TextCapitalization.characters : TextCapitalization.none,
          inputFormatters: [
            if (allowedPattern != null)
              FilteringTextInputFormatter.allow(
                RegExp(allowedPattern!),
              ),
            if (forceUppercase) _UpperCaseTextFormatter(),
          ],
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.headingNavy,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFE53935)
                    : const Color(0xFFD5DDE5),
                width: 1.2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.emerald, width: 2),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE53935), width: 1.2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
          ),
        ] else if (example != null && example!.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            example!,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
