import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/model/city_model.dart';

class FeaturedCityChip extends StatelessWidget {
  final City city;
  final bool isSelected;
  final VoidCallback onTap;

  const FeaturedCityChip({
    super.key,
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (city.id) {
      case 'chennai':
        return Icons.location_city_rounded;
      case 'mumbai':
        return Icons.architecture_rounded;
      case 'delhi':
        return Icons.account_balance_rounded;
      default:
        return Icons.location_city_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 100,
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.emerald : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 28,
              color: isSelected ? AppColors.emerald : const Color(0xFF8FA0B0),
            ),
            const SizedBox(height: 8),
            Text(
              city.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: const Color(0xFF3D4F63),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
