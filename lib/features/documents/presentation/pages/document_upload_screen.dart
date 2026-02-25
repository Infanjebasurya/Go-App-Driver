import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/documents/presentation/widgets/doc_number_field.dart';
import 'package:goapp/features/documents/presentation/widgets/document_capture_card.dart';
import 'package:goapp/features/documents/presentation/pages/verification_submitted_screen.dart';

import '../cubit/document_upload_cubit.dart';
import '../model/document_upload_model.dart';

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key, this.initialStepIndex = 0});

  final int initialStepIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentUploadCubit(initialStepIndex: initialStepIndex),
      child: const _DocumentUploadView(),
    );
  }
}

class _DocumentUploadView extends StatefulWidget {
  const _DocumentUploadView();

  @override
  State<_DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<_DocumentUploadView>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _docControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _buildSlideAnimation(forward: true);
    _slideCtrl.forward(from: 0);
  }

  void _buildSlideAnimation({required bool forward}) {
    _slideIn = Tween<Offset>(
      begin: Offset(forward ? 1.0 : -1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  void _animateTransition({required bool forward}) {
    _buildSlideAnimation(forward: forward);
    _slideCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    for (final c in _docControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentUploadCubit, DocumentUploadState>(
      listener: (context, state) {
        if (state.isAllDone) {
          _navigateToSuccess(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppAppBar(
            title: 'GoApp',
            onBack: () {
              if (state.canGoBack) {
                _animateTransition(forward: false);
                context.read<DocumentUploadCubit>().goBack();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: _StepLabel(
                    currentStep: state.currentStepIndex,
                    totalSteps: state.totalSteps,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SegmentedBar(
                    currentStep: state.currentStepIndex,
                    totalSteps: state.totalSteps,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SlideTransition(
                    position: _slideIn,
                    child: state.isCurrentStepBank
                        ? BankAccountForm(
                            key: const ValueKey('bank_step'),
                            bankData: state.bankData,
                          )
                        : _DocStepContent(
                            key: ValueKey(state.currentStepIndex),
                            config: state.currentConfig,
                            stepData: state.currentDocStep,
                            numberController:
                                _docControllers[state.currentStepIndex],
                          ),
                  ),
                ),
                _ActionButton(
                  isLastStep: state.isLastStep,
                  isCurrentStepBank: state.isCurrentStepBank,
                  isSubmitting: state.isSubmitting,
                  onTap: () {
                    _animateTransition(forward: true);
                    context.read<DocumentUploadCubit>().saveAndNext();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToSuccess(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const VerificationSubmittedScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepLabel({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Step ${currentStep + 1} to $totalSteps',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.emerald,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _SegmentedBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _SegmentedBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: 3.5,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              color: active ? AppColors.emerald : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _DocStepContent extends StatelessWidget {
  final StepConfig config;
  final StepData stepData;
  final TextEditingController numberController;

  const _DocStepContent({
    super.key,
    required this.config,
    required this.stepData,
    required this.numberController,
  });

  void _showImageSourceSheet(
    BuildContext context, {
    required Future<void> Function(ImageSource source) onPick,
  }) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingNavy,
                ),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onPick(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onPick(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (numberController.text != stepData.documentNumber) {
      numberController.text = stepData.documentNumber;
      numberController.selection = TextSelection.collapsed(
        offset: numberController.text.length,
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppColors.headingNavy,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            config.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          DocumentCaptureCard(
            key: ValueKey('front_${config.step.name}'),
            label: 'Front Side',
            captured: stepData.frontCaptured,
            onTap: () => _showImageSourceSheet(
              context,
              onPick: (source) => context
                  .read<DocumentUploadCubit>()
                  .captureFront(source: source),
            ),
            onRemove: () => context.read<DocumentUploadCubit>().removeFront(),
          ),
          const SizedBox(height: 14),
          DocumentCaptureCard(
            key: ValueKey('back_${config.step.name}'),
            label: 'Back Side',
            captured: stepData.backCaptured,
            onTap: () => _showImageSourceSheet(
              context,
              onPick: (source) => context
                  .read<DocumentUploadCubit>()
                  .captureBack(source: source),
            ),
            onRemove: () => context.read<DocumentUploadCubit>().removeBack(),
          ),
          if (stepData.imageError != null) ...[
            const SizedBox(height: 10),
            Text(
              stepData.imageError!,
              style: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
            ),
          ],
          const SizedBox(height: 28),
          DocNumberField(
            key: ValueKey('number_${config.step.name}'),
            label: config.numberLabel,
            hint: config.numberHint,
            example: config.numberExample.isNotEmpty
                ? config.numberExample
                : null,
            controller: numberController,
            errorText: stepData.numberError,
            onChanged: (v) =>
                context.read<DocumentUploadCubit>().updateDocumentNumber(v),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isLastStep;
  final bool isCurrentStepBank;
  final bool isSubmitting;
  final VoidCallback onTap;

  const _ActionButton({
    required this.isLastStep,
    required this.isCurrentStepBank,
    required this.isSubmitting,
    required this.onTap,
  });

  String get _label {
    if (isCurrentStepBank) return 'Save & Verify';
    if (isLastStep) return 'Submit All Documents';
    return 'Save & Next';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.coolwhite)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          key: const Key('save_next_button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          onPressed: isSubmitting ? null : onTap,
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _label,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
        ),
      ),
    );
  }
}

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
              color: AppColors.headingNavy,
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
                _obscureAccount
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
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
                        color: AppColors.headingNavy,
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
            color: AppColors.headingNavy,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade400),
            suffixIcon: suffixIcon,
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
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
          ),
        ],
      ],
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
