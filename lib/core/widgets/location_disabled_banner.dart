import 'package:flutter/material.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/theme/app_colors.dart';

class LocationDisabledBanner extends StatelessWidget {
  const LocationDisabledBanner({
    super.key,
    required this.issue,
    required this.onActionTap,
  });

  final LocationIssue issue;
  final VoidCallback onActionTap;

  String get _message {
    switch (issue) {
      case LocationIssue.serviceDisabled:
        return 'Location is turned off. Enable location services to use live map tracking.';
      case LocationIssue.permissionDenied:
        return 'Location permission is required for this map. Please allow location access.';
      case LocationIssue.permissionDeniedForever:
        return 'Location permission is permanently denied. Open app settings and enable it.';
    }
  }

  String get _actionLabel {
    switch (issue) {
      case LocationIssue.serviceDisabled:
        return 'Enable Location';
      case LocationIssue.permissionDenied:
      case LocationIssue.permissionDeniedForever:
        return 'Open Settings';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_off_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _actionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
