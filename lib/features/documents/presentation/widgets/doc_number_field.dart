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
  final int? maxLength;
  final bool formatAsAadhaar;
  final bool formatAsPan;
  final bool formatAsVehicleNumber;
  final bool formatAsDrivingLicense;

  const DocNumberField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.allowedPattern,
    this.forceUppercase = false,
    this.maxLength,
    this.formatAsAadhaar = false,
    this.formatAsPan = false,
    this.formatAsVehicleNumber = false,
    this.formatAsDrivingLicense = false,
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
            color: hasError ? AppColors.hexFFE53935 : AppColors.hexFF8FA0B0,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          textCapitalization: forceUppercase
              ? TextCapitalization.characters
              : TextCapitalization.none,
          inputFormatters: [
            if (allowedPattern != null)
              FilteringTextInputFormatter.allow(RegExp(allowedPattern!)),
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
            if (forceUppercase) _UpperCaseTextFormatter(),
            if (formatAsAadhaar) _AadhaarTextFormatter(),
            if (formatAsPan) _PanTextFormatter(),
            if (formatAsVehicleNumber) _VehicleNumberTextFormatter(),
            if (formatAsDrivingLicense) _DrivingLicenseTextFormatter(),
          ],
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.headingNavy,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            fillColor: AppColors.white,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppColors.gray.shade400,
              fontWeight: FontWeight.w400,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.hexFFE53935 : AppColors.hexFFD5DDE5,
                width: 1.2,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.hexFFE53935 : AppColors.emerald,
                width: 2,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.hexFFE53935, width: 1.2),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.hexFFE53935, width: 2),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 11, color: AppColors.hexFFE53935),
          ),
        ] else if (example != null && example!.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            example!,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.gray.shade400,
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

class _AadhaarTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = digitsOnly.length > 12
        ? digitsOnly.substring(0, 12)
        : digitsOnly;

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      buffer.write(trimmed[i]);
      if ((i + 1) % 4 == 0 && i + 1 != trimmed.length) {
        buffer.write(' ');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PanTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      final index = buffer.length;
      if (index >= 10) break;

      final isAlphabet = RegExp(r'[A-Z]').hasMatch(char);
      final isDigit = RegExp(r'[0-9]').hasMatch(char);

      if (index < 5 && isAlphabet) {
        buffer.write(char);
      } else if (index >= 5 && index < 9 && isDigit) {
        buffer.write(char);
      } else if (index == 9 && isAlphabet) {
        buffer.write(char);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _VehicleNumberTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      final index = buffer.length;
      if (index >= 10) break;

      final isAlphabet = RegExp(r'[A-Z]').hasMatch(char);
      final isDigit = RegExp(r'[0-9]').hasMatch(char);

      if (index < 2 && isAlphabet) {
        buffer.write(char);
      } else if (index >= 2 && index < 4 && isDigit) {
        buffer.write(char);
      } else if (index >= 4 && index < 6 && isAlphabet) {
        buffer.write(char);
      } else if (index >= 6 && index < 10 && isDigit) {
        buffer.write(char);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DrivingLicenseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      final index = buffer.length;
      if (index >= 15) break;

      final isAlphabet = RegExp(r'[A-Z]').hasMatch(char);
      final isDigit = RegExp(r'[0-9]').hasMatch(char);

      if (index < 2 && isAlphabet) {
        buffer.write(char);
      } else if (index >= 2 && index < 15 && isDigit) {
        buffer.write(char);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
