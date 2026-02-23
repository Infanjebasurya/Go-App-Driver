import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

import '../cubit/document_upload_cubit.dart';
import '../model/document_upload_model.dart';

class BankAccountForm extends StatefulWidget {
  final BankAccountData bankData;

  const BankAccountForm({super.key, required this.bankData});

  @override
  State<BankAccountForm> createState() => _BankAccountFormState();
}

class _BankAccountFormState extends State<BankAccountForm> {
  final _nameCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  bool _obscureAccount = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.bankData.accountHolderName;
    _accCtrl.text = widget.bankData.accountNumber;
    _confirmCtrl.text = widget.bankData.confirmAccountNumber;
    _ifscCtrl.text = widget.bankData.ifscCode;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accCtrl.dispose();
    _confirmCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.bankData;
    final cubit = context.read<DocumentUploadCubit>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Link Bank Account',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2236),
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Securely link your account for direct payouts',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30),
          _BankField(
            label: 'Account Holder Name',
            hint: 'Enter full name as per bank records',
            controller: _nameCtrl,
            errorText: data.nameError,
            onChanged: cubit.updateAccountHolderName,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          _BankField(
            label: 'Account Number',
            hint: '•••• •••• •••• ••••',
            controller: _accCtrl,
            errorText: data.accountNumberError,
            onChanged: cubit.updateAccountNumber,
            keyboardType: TextInputType.number,
            obscureText: _obscureAccount,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureAccount = !_obscureAccount),
              child: Icon(
                _obscureAccount ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: const Color(0xFF8FA0B0),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _BankField(
            label: 'Confirm Account Number',
            hint: 'Re-enter account number',
            controller: _confirmCtrl,
            errorText: data.confirmAccountNumberError,
            onChanged: cubit.updateConfirmAccountNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),
          _BankField(
            label: 'IFSC Code',
            hint: 'HDFC0000000',
            controller: _ifscCtrl,
            errorText: data.ifscError,
            onChanged: (v) => cubit.updateIfscCode(v.toUpperCase()),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(11),
              _UpperCaseFormatter(),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: AppColors.gold, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Security Guaranteed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2236),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your data is encrypted and managed according to\npremium banking standards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BankField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  const _BankField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.suffixIcon,
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
          keyboardType: keyboardType,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A2236),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
            ),
            suffixIcon: suffixIcon,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFE53935) : const Color(0xFFD5DDE5),
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
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFE53935),
            ),
          ),
        ],
      ],
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
