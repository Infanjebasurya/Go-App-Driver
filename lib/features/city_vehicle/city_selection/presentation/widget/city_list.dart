import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/model/city_model.dart';

class CityListTile extends StatelessWidget {
  final City city;
  final bool isSelected;
  final VoidCallback onTap;

  const CityListTile({
    super.key,
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F4F8), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                city.name,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.emerald : const Color(0xFF1A2236),
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.emerald,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
