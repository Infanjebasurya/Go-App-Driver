import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class RechargeSuccessPage extends StatelessWidget {
  const RechargeSuccessPage({super.key, required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(flex: 3),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.emerald,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 64),
            ),
            const SizedBox(height: 40),
            const Text(
              'Recharge\nSuccessful',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 32),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.neutral666,
                  height: 1.5,
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: '\u20B9$amount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontSize: 18,
                    ),
                  ),
                  const TextSpan(
                    text: ' has been added to\nyour GoApp Wallet.',
                  ),
                ],
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ShadowButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Back to Wallet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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




