import 'package:flutter/material.dart';
import 'package:goapp/features/earnings/presentation/pages/recharge_wallet_page.dart';
import 'package:goapp/core/theme/app_colors.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '?5,430.50',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RechargeWalletPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle, size: 20),
                          label: const Text('Recharge Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.account_balance_wallet, size: 20),
                          label: const Text('Withdraw'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Earning Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                Row(
                  children: [
                    _buildLegendDot(AppColors.emerald, 'Weekday'),
                    const SizedBox(width: 12),
                    _buildLegendDot(AppColors.gold, 'Weekend'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildBarChart(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTransactionItem(
              icon: Icons.local_taxi,
              iconColor: AppColors.emerald,
              iconBgColor: AppColors.earningsAccentSoft,
              title: 'Trip Earning #8294',
              subtitle: 'Today, 2:45 PM',
              amount: '+?850.00',
              isCredit: true,
            ),
            const SizedBox(height: 16),
            _buildTransactionItem(
              icon: Icons.account_balance,
              iconColor: Colors.grey,
              iconBgColor: Colors.grey[100]!,
              title: 'Bank Transfer',
              subtitle: 'Today, 2:45 PM',
              amount: '+?850.00',
              isCredit: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => const Divider(color: AppColors.strokeLight, height: 1),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('M', 0.6, false),
              _buildBar('T', 0.5, false),
              _buildBar('W', 0.8, false),
              _buildBar('T', 0.4, false),
              _buildBar('F', 0.7, false),
              _buildBar('S', 0.9, true),
              _buildBar('S', 0.05, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percentage, bool isWeekend) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 6,
          height: 150 * percentage,
          decoration: BoxDecoration(
            color: isWeekend ? AppColors.gold : AppColors.emerald,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isCredit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}


