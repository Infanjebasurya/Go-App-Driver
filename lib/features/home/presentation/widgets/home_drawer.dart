import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/about/presentation/pages/about_screen.dart';
import 'package:goapp/features/demand_planner/presentation/pages/demand_planner_screen.dart';
import 'package:goapp/features/documents/presentation/pages/documents_screen.dart';
import 'package:goapp/features/earnings/presentation/pages/earnings_screen.dart';
import 'package:goapp/features/incentives/presentation/pages/incentives_page.dart';
import 'package:goapp/features/help_support/presentation/pages/help_support_screen.dart';
import 'package:goapp/features/profile/presentation/pages/profile_screen.dart';
import 'package:goapp/features/refer_earn/presentation/pages/refer_earn_screen.dart';
import 'package:goapp/features/rate_app/presentation/pages/rate_app_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/300'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.verifiedMint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sam Yogi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.earningsAccentSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.earningsAccentLine),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: AppColors.greenStrong,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'PLATINUM MEMBER',
                    style: TextStyle(
                      color: AppColors.greenStrong,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Earning & Wallet',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EarningsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.monetization_on_outlined,
              title: 'Incentives',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncentivesPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Documents',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.trending_up,
              title: 'Demand Planner',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DemandPlannerScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Refer & Earn',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReferEarnScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.star_border,
              title: 'Rate App',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RateAppScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
