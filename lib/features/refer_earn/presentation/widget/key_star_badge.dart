import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class KeyWithStarBadge extends StatelessWidget {
  final double size;

  const KeyWithStarBadge({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const RadialGradient(
            center: Alignment(0, 0),
            radius: 0.75,
            colors: [
              AppColors.referGlowStart,
              AppColors.referGlowMid,
              AppColors.white,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.vpn_key_rounded,
              size: size * 0.38,
              color: AppColors.emerald,
            ),
            Positioned(
              right: size * 0.18,
              top: size * 0.13,
              child: Container(
                width: size * 0.18,
                height: size * 0.18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.referBadgeAccent,
                ),
                child: Center(
                  child: Icon(
                    Icons.star_rounded,
                    size: size * 0.12,
                    color: AppColors.earningsAccentSoft,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
