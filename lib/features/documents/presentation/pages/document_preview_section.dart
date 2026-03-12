import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';

import '../model/document_upload_model.dart';

class ProfilePhotoStepContent extends StatelessWidget {
  const ProfilePhotoStepContent({
    super.key,
    required this.stepData,
    required this.isProcessing,
    required this.onCameraTap,
  });

  final StepData stepData;
  final bool isProcessing;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    const double passportAspectRatio = 3.5 / 4.5;
    final double frameWidth =
        (shortestSide * 0.52).clamp(210.0, 260.0).toDouble();
    const double borderRadius = 16;
    final hasImage = stepData.frontCaptured &&
        stepData.frontPath != null &&
        stepData.frontPath!.isNotEmpty &&
        File(stepData.frontPath!).existsSync();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.headingNavy,
                letterSpacing: -0.6,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your profile picture',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: frameWidth,
                child: AspectRatio(
                  aspectRatio: passportAspectRatio,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: (isProcessing || hasImage) ? null : onCameraTap,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(borderRadius),
                              border: Border.all(
                                color: AppColors.emerald,
                                width: 2.5,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: hasImage
                                ? Image.file(
                                    File(stepData.frontPath!),
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.person,
                                    size: frameWidth * 0.42,
                                    color: Colors.white54,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: GestureDetector(
                          onTap: isProcessing ? null : onCameraTap,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                              border: Border.all(
                                color: AppColors.emerald,
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color:
                                  isProcessing ? Colors.black26 : AppColors.emerald,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isProcessing)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
                ),
              ),
            if (stepData.imageError != null) ...[
              const SizedBox(height: 10),
              Text(
                stepData.imageError!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
