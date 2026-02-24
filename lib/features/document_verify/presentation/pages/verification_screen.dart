import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/documents/presentation/pages/document_upload_screen.dart';
import 'package:goapp/core/storage/registration_progress_store.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_cubit.dart';
import 'package:goapp/features/home/presentation/pages/home_page.dart';

import '../cubit/verification_cubit.dart';
import '../model/document_model.dart';
import '../widgets/document_card.dart';
import '../widgets/verification_progress_card.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationCubit(),
      child: const _VerificationView(),
    );
  }
}

class _VerificationView extends StatefulWidget {
  const _VerificationView();

  @override
  State<_VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<_VerificationView> {
  @override
  void initState() {
    super.initState();
    unawaited(
      RegistrationProgressStore.setStep(RegistrationStep.verification),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(
        title: 'GoApp',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EDF2)),
        ),
      ),
      body: BlocConsumer<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state.isSubmitted) {
            _showSuccessDialog(context);
          }
          if (state.errorMessage != null) {
            _showErrorSnackbar(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Professional Credentials',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingNavy,
                            letterSpacing: -0.6,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Step 1 to 5',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      VerificationProgressCard(
                        completedCount: state.completedCount,
                        totalCount: state.documents.length,
                        progressPercent: state.progressPercent,
                      ),
                      const SizedBox(height: 8),
                      ...state.documents.map(
                        (doc) => DocumentCard(
                          key: ValueKey(doc.type),
                          document: doc,
                          onTap: () => _handleDocumentTap(context, doc, state),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _SubmitSection(state: state),
            ],
          );
        },
      ),
    );
  }

  void _handleDocumentTap(
    BuildContext context,
    Document doc,
    VerificationState state,
  ) {
    final stepIndex = _stepIndexForDoc(doc.type);
    if (stepIndex != null) {
      unawaited(
        RegistrationProgressStore.setStep(
          RegistrationStep.documentUpload,
          documentStepIndex: stepIndex,
        ),
      );
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => DocumentUploadScreen(initialStepIndex: stepIndex),
            ),
          )
          .then((_) {
            if (!context.mounted) return;
            context.read<VerificationCubit>().syncFromStore();
          });
      return;
    }
  }

  int? _stepIndexForDoc(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return 0;
      case DocumentType.vehicleRC:
        return 1;
      case DocumentType.aadhaarCard:
        return 2;
      case DocumentType.panCard:
        return 3;
      case DocumentType.bankDetails:
        return 4;
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: AppColors.emerald,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.headingNavy,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your documents have been submitted for review. We\'ll notify you once verified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF6B7C93),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<VerificationCubit>().reset();
                  RegistrationProgressStore.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider<DriverCubit>(
                        create: (_) => DriverCubit(),
                        child: const HomeScreen(),
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

class _SubmitSection extends StatelessWidget {
  final VerificationState state;

  const _SubmitSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        math.max(
              MediaQuery.viewInsetsOf(context).bottom,
              MediaQuery.of(context).padding.bottom,
            ) +
            16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EDF2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('submit_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFB0D9CC),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: state.isSubmitting
                  ? null
                  : () => context.read<VerificationCubit>().submitForReview(),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SUBMIT FOR REVIEW',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 5),
              Text(
                'ENCRYPTED ELITE VERIFICATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
