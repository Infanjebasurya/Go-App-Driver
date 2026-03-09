import 'package:flutter/material.dart';

import '../../../cubit/profile_edit_state.dart';



class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.data});

  final ProfileEditData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _StatCell(
            label: 'RATING',
            value: '${data.rating}',
            suffix: Icons.star,
            suffixColor: const Color(0xFFFFB800),
          ),
          _divider(),
          _StatCell(label: 'TOTAL TRIPS', value: '${data.totalTrips}'),
          _divider(),
          _StatCell(label: 'TOTAL YEARS', value: '${data.totalYears}'),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: const Color(0xFFF0F0F0));
}

class _StatCell extends StatelessWidget {
  const _StatCell({
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
    return Expanded(
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
