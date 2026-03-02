import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/storage/user_cache_store.dart';

import '../../../about/presentation/pages/about_screen.dart';
import '../../../auth/presentation/theme/auth_ui_tokens.dart';
import '../../../demand_planner/presentation/pages/demand_planner_screen.dart';
import '../../../documents/presentation/pages/documents_screen.dart';
import '../../../earnings/presentation/pages/earnings_screen.dart';
import '../../../help_support/presentation/pages/help_support_screen.dart';
import '../../../incentives/presentation/pages/incentives_page.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../rate_app/presentation/pages/rate_app_screen.dart';
import '../../../refer_earn/presentation/pages/refer_earn_screen.dart';
import '../../../ride_history/presentation/pages/ride_history_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key, required this.onReopenDrawer});

  final VoidCallback onReopenDrawer;

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
            _ProfileHeader(
              context: context,
              onReopenDrawer: onReopenDrawer,
            ),

            const SizedBox(height: 16),

            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 16),

            _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Earning & Wallet',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EarningsScreen()),
                ).then((_) => onReopenDrawer());
              },
            ),
            _DrawerItem(
              icon: Icons.card_giftcard_outlined,
              label: 'Incentives',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncentivesPage()),
                ).then((_) => onReopenDrawer());
              },
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              label: 'Documents',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                ).then((_) => onReopenDrawer());
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
                ).then((_) => onReopenDrawer());
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
                ).then((_) => onReopenDrawer());
              },
            ),
            _DrawerItem(
              icon: Icons.history,
              label: 'Ride History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RideHistoryScreen()),
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
                ).then((_) => onReopenDrawer());
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
                ).then((_) => onReopenDrawer());
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
                ).then((_) => onReopenDrawer());
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatefulWidget {
  final BuildContext context;
  final VoidCallback onReopenDrawer;

  const _ProfileHeader({
    required this.context,
    required this.onReopenDrawer,
  });

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  static const String _photoKey = 'profile.photo.path';
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _photoPath = TextFieldStore.read(_photoKey);
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    _photoPath = picked.path;
    await TextFieldStore.write(_photoKey, picked.path);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (UserCacheStore.read()?.fullName ?? 'Sam Yogi').trim();
    final displayName = name.isEmpty ? 'Sam Yogi' : name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 16, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(widget.context);
          Navigator.push(
            widget.context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ).then((_) => widget.onReopenDrawer());
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
                          child: _photoPath != null &&
                                  _photoPath!.isNotEmpty &&
                                  File(_photoPath!).existsSync()
                              ? Image.file(
                                  File(_photoPath!),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
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
                      child: GestureDetector(
                        onTap: _pickPhoto,
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
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  displayName,
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
                          color: AuthUiColors.brandGreen,
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
