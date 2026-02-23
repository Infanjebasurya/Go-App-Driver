import 'package:flutter/material.dart';

import '../../../about/presentation/pages/about_screen.dart';
import '../../../auth/presentation/theme/auth_ui_tokens.dart';
import '../../../demand_planner/presentation/pages/demand_planner_screen.dart';
import '../../../documents/presentation/pages/documents_screen.dart';
import '../../../help_support/presentation/pages/help_support_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../rate_app/presentation/pages/rate_app_screen.dart';
import '../../../refer_earn/presentation/pages/refer_earn_screen.dart';


class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _ProfileHeader(context: context),

            const SizedBox(height: 16),


            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 16),


            _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Earning & Wallet',
              onTap: () => _navigate(context, 'Earning & Wallet'),
            ),
            _DrawerItem(
              icon: Icons.card_giftcard_outlined,
              label: 'Incentives',
              onTap: () => _navigate(context, 'Incentives'),
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              label: 'Documents',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DocumentsScreen(),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.insights_outlined,
              label: 'Demand Planner',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DemandPlannerScreen(),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.share_outlined,
              label: 'Refer & Earn',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReferEarnScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 8),


            _DrawerItem(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutScreen(),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.star_outline,
              label: 'Rate App',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RateAppScreen(),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpSupportScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlaceholderPage(title: page),
      ),
    );
  }
}


class _ProfileHeader extends StatelessWidget {
  final BuildContext context;
  const _ProfileHeader({required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 16, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AuthUiColors.brandGreen,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF3A3A3A),
                          child: const Icon(
                            Icons.person,
                            size: 44,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AuthUiColors.brandGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sam Yogi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AuthUiColors.brandGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AuthUiColors.brandGreen.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AuthUiColors.brandGreen,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PLATINUM MEMBER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:AuthUiColors.brandGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AuthUiColors.brandGreen.withOpacity(0.08),
      highlightColor: AuthUiColors.brandGreen.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: const Color(0xFF444444),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}


class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AuthUiColors.brandGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.construction_outlined,
                color: AuthUiColors.brandGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming soon...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}