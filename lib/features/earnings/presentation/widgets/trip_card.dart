import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class TripCard extends StatelessWidget {
  final String date;
  final String timeRange;
  final String price;
  final String pickupLocation;
  final String pickupAddress;
  final String dropLocation;
  final String dropAddress;
  final String? statusLine;

  final bool isCancelled;

  const TripCard({
    super.key,
    required this.date,
    required this.timeRange,
    required this.price,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.dropLocation,
    required this.dropAddress,
    this.statusLine,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isCancelled
        ? AppColors.validationRed
        : AppColors.emerald;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeRange,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray[600],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (statusLine != null && statusLine!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            statusLine!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray[600],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            _LocationLine(
              icon: Icons.trip_origin_rounded,
              iconColor: accentColor,
              accentColor: accentColor,
              label: pickupLocation,
              value: pickupAddress,
              showConnector: true,
            ),
            _LocationLine(
              icon: Icons.location_on,
              iconColor: AppColors.black,
              accentColor: accentColor,
              label: dropLocation,
              value: dropAddress,
              showConnector: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.label,
    required this.value,
    required this.showConnector,
  });

  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final String label;
  final String value;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
            child: Column(
              children: <Widget>[
                Icon(icon, size: 16, color: iconColor),
                if (showConnector)
                  Container(
                    width: 1.2,
                    height: 26,
                    margin: const EdgeInsets.only(top: 3),
                    color: accentColor,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral333,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
