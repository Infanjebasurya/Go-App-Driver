import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/auth/presentation/widgets/snackbar_utils.dart';
import 'package:goapp/features/documents/presentation/pages/document_upload_screen.dart';
import 'package:goapp/core/storage/registration_progress_store.dart';
import 'package:goapp/features/documents/presentation/pages/verification_submitted_screen.dart';

import '../cubit/verification_cubit.dart';
import '../cubit/verification_state.dart';
import '../model/document_model.dart';
import '../widgets/document_card.dart';
import '../widgets/verification_progress_card.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

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
  bool _navigated = false;
  @override
  void initState() {
    super.initState();
    unawaited(
      RegistrationProgressStore.setStep(RegistrationStep.verification),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppAppBar(
          title: 'GoApp',
          backEnabled: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE8EDF2)),
          ),
        ),
        body: BlocConsumer<VerificationCubit, VerificationState>(
          listener: (context, state) {
            if (state.isSubmitted && !_navigated) {
              _navigated = true;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VerificationSubmittedScreen(),
                ),
              );
              context.read<VerificationCubit>().clearSubmitted();
            }
            if (state.errorMessage != null) {
              _showErrorSnackbar(context, state.errorMessage!);
              context.read<VerificationCubit>().clearError();
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
                            'Step 1 to 6',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        VerificationProgressCard(
                          completedCount: state.completedCountWithProfile,
                          totalCount: state.totalRequiredCount,
                          progressPercent: state.progressPercent,
                        ),
                        const SizedBox(height: 8),
                        _ProfilePictureCard(
                          isCompleted: state.isProfileImageUploaded,
                          onTap: () => _openProfileStep(context),
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
        return 1;
      case DocumentType.vehicleRC:
        return 2;
      case DocumentType.aadhaarCard:
        return 3;
      case DocumentType.panCard:
        return 4;
      case DocumentType.bankDetails:
        return 5;
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    SnackBarUtils.showError(context, message);
  }

  void _openProfileStep(BuildContext context) {
    unawaited(
      RegistrationProgressStore.setStep(
        RegistrationStep.documentUpload,
        documentStepIndex: 0,
      ),
    );
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => const DocumentUploadScreen(
          initialStepIndex: 0,
        ),
      ),
    )
        .then((_) {
      if (!context.mounted) return;
      context.read<VerificationCubit>().syncFromStore();
    });
  }
}

class _ProfilePictureCard extends StatelessWidget {
  const _ProfilePictureCard({
    required this.isCompleted,
    required this.onTap,
  });

  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? AppColors.emerald.withValues(alpha: 0.3)
                : const Color(0xFFE8EDF2),
            width: isCompleted ? 1.5 : 1,
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
              SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.person_rounded,
                  color:
                      isCompleted ? AppColors.emerald : const Color(0xFF8FA0B0),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.headingNavy,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
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
                )
              else
                Container(
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
                ),
            ],
          ),
        ),
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
            child: ShadowButton(
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

