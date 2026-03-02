import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class WithdrawalSuccessPage extends StatelessWidget {
  const WithdrawalSuccessPage({
    super.key,
    required this.amount,
    required this.bankName,
  });

  final String amount;
  final String bankName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(flex: 2),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceF5,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.strokeLight,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 48,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Withdrawal Initiated',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.neutral666,
                    height: 1.5,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: '₹$amount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const TextSpan(text: ' is on its way to your '),
                    TextSpan(
                      text: bankName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const TextSpan(text: ' bank account.'),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
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

