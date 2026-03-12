import 'package:flutter/material.dart';

import '../../../cubit/profile_edit_state.dart';



class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.data});

  final ProfileEditData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'RATING',
              value: '${data.rating}',
              suffix: Icons.star,
              suffixColor: const Color(0xFFFFB800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(label: 'TOTAL TRIPS', value: '${data.totalTrips}'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(label: 'TOTAL YEARS', value: '${data.totalYears}'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.suffix,
    this.suffixColor,
  });

  final String label;
  final String value;
  final IconData? suffix;
  final Color? suffixColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFAAAAAA),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (suffix != null) ...<Widget>[
                const SizedBox(width: 3),
                Icon(suffix, color: suffixColor, size: 14),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
