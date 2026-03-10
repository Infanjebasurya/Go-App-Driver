import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/storage/profile_display_store.dart';
import 'dart:io';

class RiderContactHeader extends StatelessWidget {
  const RiderContactHeader({
    super.key,
    required this.onBackTap,
    required this.onActionTap,
    required this.actionIcon,
    this.name = '',
    this.idLabel = 'ID 123456',
    this.rating = '4.9',
  });

  final VoidCallback onBackTap;
  final VoidCallback onActionTap;
  final IconData actionIcon;
  final String name;
  final String idLabel;
  final String rating;

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty
        ? ProfileDisplayStore.displayName()
        : name;
    final profilePath = ProfileDisplayStore.photoPath();
    final double topInset = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(14, topInset + 8, 14, 12),
      child: Row(
        children: <Widget>[
          _CircleButton(icon: Icons.chevron_left, onTap: onBackTap),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: profilePath != null
                  ? Image.file(File(profilePath), fit: BoxFit.cover)
                  : Image.asset('assets/image/profile.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18 / 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral333,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: AppColors.starYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral666,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      idLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral888,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _CircleButton(icon: actionIcon, onTap: onActionTap),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: AppColors.neutral444, size: 21),
        ),
      ),
    );
  }
}



