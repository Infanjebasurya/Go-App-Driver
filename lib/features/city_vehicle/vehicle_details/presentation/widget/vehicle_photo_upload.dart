import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/model/vehicle_details_model.dart';

class VehiclePhotoUpload extends StatelessWidget {
  final bool hasPhoto;
  final String? uploadPath;
  final String? uploadName;
  final VehicleUploadType? uploadType;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VehicleType vehicleType;

  const VehiclePhotoUpload({
    super.key,
    required this.hasPhoto,
    this.uploadPath,
    this.uploadName,
    this.uploadType,
    required this.onTap,
    required this.vehicleType,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasPhoto ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: hasPhoto
              ? AppColors.emerald.withValues(alpha: 0.06)
              : AppColors.hexFFF8FAFC,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasPhoto
                ? AppColors.emerald.withValues(alpha: 0.4)
                : AppColors.hexFFE2E8F0,
            width: hasPhoto ? 1.5 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: hasPhoto
            ? _UploadedState(
                onRemove: onRemove,
                uploadPath: uploadPath,
                uploadName: uploadName,
                uploadType: uploadType,
              )
            : _EmptyState(vehicleType: vehicleType),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.vehicleType});

  final VehicleType vehicleType;

  IconData get _icon {
    switch (vehicleType) {
      case VehicleType.bike:
        return Icons.two_wheeler_rounded;
      case VehicleType.auto:
        return Icons.electric_rickshaw_rounded;
      case VehicleType.cab:
        return Icons.local_taxi_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Icon(_icon, size: 50, color: AppColors.hexFF8FA0B0),
        ),
        const SizedBox(height: 10),
        const Text(
          'Upload Vehicle Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.headingNavy,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _UploadedState extends StatelessWidget {
  final VoidCallback? onRemove;
  final String? uploadPath;
  final String? uploadName;
  final VehicleUploadType? uploadType;

  const _UploadedState({
    this.onRemove,
    this.uploadPath,
    this.uploadName,
    this.uploadType,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = uploadType == VehicleUploadType.image && uploadPath != null;
    final isDocument =
        uploadType == VehicleUploadType.document && uploadPath != null;

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(uploadPath!),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackIcon(),
                  ),
                )
              else
                _fallbackIcon(isDocument: isDocument),
              if (isDocument &&
                  uploadName != null &&
                  uploadName!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        uploadName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.hexFFFFEEEE,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.hexFFE53935,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallbackIcon({bool isDocument = false}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isDocument ? Icons.description_rounded : Icons.check_rounded,
        size: 32,
        color: AppColors.emerald,
      ),
    );
  }
}




