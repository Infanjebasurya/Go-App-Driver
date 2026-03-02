import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/home/presentation/widgets/home_no_device_back.dart';
import 'package:goapp/features/home/presentation/widgets/rider_contact_header.dart';

class RideCallPage extends StatelessWidget {
  const RideCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeNoDeviceBack(
      child: Scaffold(
        backgroundColor: AppColors.surfaceF5,
        body: Column(
          children: <Widget>[
            RiderContactHeader(
              onBackTap: () => Navigator.of(context).pop(),
              onActionTap: () {},
              actionIcon: Icons.call,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/profile.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Calling Sam Yogi...',
                    style: TextStyle(
                      fontSize: 18 / 1.08,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral333,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ringing',
                    style: TextStyle(
                      fontSize: 14 / 1.08,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral666,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 34),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: AppColors.sosCallRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end_rounded,
                    color: AppColors.white,
                    size: 32,
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
