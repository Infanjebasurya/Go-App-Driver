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
    final double avatarSize =
        (shortestSide * 0.38).clamp(182.0, 196.0).toDouble();
    final double cameraSize =
        (avatarSize * 0.2).clamp(40.0, 45.0).toDouble();
    final double cameraIconSize =
        (cameraSize * 0.58).clamp(15.0, 20.0).toDouble();
    final hasImage = stepData.frontCaptured &&
        stepData.frontPath != null &&
        stepData.frontPath!.isNotEmpty &&
        File(stepData.frontPath!).existsSync();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
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
          const SizedBox(height: 48),
          Center(
            child: Stack(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.emerald, width: 2.5),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.grey.shade200,
                      child: hasImage
                          ? Image.file(
                              File(stepData.frontPath!),
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.person,
                              size: avatarSize * 0.55,
                              color: Colors.white54,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: isProcessing ? null : onCameraTap,
                    child: Container(
                      width: cameraSize,
                      height: cameraSize,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: cameraIconSize,
                      ),
                    ),
                  ),
                ),
              ],
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
          const Spacer(),
        ],
      ),
    );
  }
}
