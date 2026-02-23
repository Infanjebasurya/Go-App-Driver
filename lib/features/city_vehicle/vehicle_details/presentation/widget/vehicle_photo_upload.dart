import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';

class VehiclePhotoUpload extends StatelessWidget {
  final bool hasPhoto;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VehicleType vehicleType;

  const VehiclePhotoUpload({
    super.key,
    required this.hasPhoto,
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
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasPhoto
                ? AppColors.emerald.withValues(alpha: 0.4)
                : const Color(0xFFE2E8F0),
            width: hasPhoto ? 1.5 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: hasPhoto
            ? _UploadedState(onRemove: onRemove)
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _icon,
            size: 50,
            color: const Color(0xFF8FA0B0),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Upload Vehicle Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2236),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _UploadedState extends StatelessWidget {
  final VoidCallback? onRemove;

  const _UploadedState({this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 28,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Photo uploaded',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.emerald,
                ),
              ),
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
                  color: Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
