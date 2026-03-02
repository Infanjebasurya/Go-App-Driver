import 'package:flutter/material.dart';

import 'package:goapp/features/about/presentation/pages/about_screen.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/documents/presentation/pages/documents_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/help_support_screen.dart';
import 'package:goapp/features/profile/presentation/pages/profile_screen.dart';
import 'package:goapp/features/rate_app/presentation/pages/rate_app_screen.dart';
import 'package:goapp/features/refer_earn/presentation/pages/refer_earn_screen.dart';

class ActivationLimitedDrawer extends StatelessWidget {
  const ActivationLimitedDrawer({super.key});

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
              icon: Icons.description_outlined,
              label: 'Documents',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentsScreen()),
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
                  MaterialPageRoute(builder: (_) => const ReferEarnScreen()),
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
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
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
                  MaterialPageRoute(builder: (_) => const RateAppScreen()),
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
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                );
              },
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6ECF3)),
              ),
              child: const Text(
                'Demand Planner, Ride History and Incentives will unlock after wallet activation.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF637488),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
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
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
                    color: AuthUiColors.brandGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AuthUiColors.brandGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pending_actions_rounded,
                        color: AuthUiColors.brandGreen,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ACTIVATION PENDING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AuthUiColors.brandGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.chevron_right, color: Colors.grey, size: 22),
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
      splashColor: AuthUiColors.brandGreen.withValues(alpha: 0.08),
      highlightColor: AuthUiColors.brandGreen.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF444444)),
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
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
