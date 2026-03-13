import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/pages/update_aadhaar_pan_details_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/update_driving_license_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/update_mobile_number_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/update_rc_details_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/about_goapp_id_card_screen.dart';

class NewAccountScreen extends StatelessWidget {
  const NewAccountScreen({super.key});

  static const List<_AccountItem> _items = <_AccountItem>[
    _AccountItem(
      title: 'Update RC details',
      destination: UpdateRcDetailsScreen(),
      chevronKey: 'account_item_update_rc_chevron',
    ),
    _AccountItem(
      title: 'Update mobile number',
      destination: UpdateMobileNumberScreen(),
      chevronKey: 'account_item_update_mobile_chevron',
    ),
    _AccountItem(
      title: 'Update driving license',
      destination: UpdateDrivingLicenseScreen(),
      chevronKey: 'account_item_update_dl_chevron',
    ),
    _AccountItem(
      title: 'Update Aadhaar / PAN details',
      destination: UpdateAadhaarPanDetailsScreen(),
      chevronKey: 'account_item_update_aadhaar_pan_chevron',
    ),
    _AccountItem(
      title: 'About GoApp ID card',
      destination: AboutGoAppIdCardScreen(),
      chevronKey: 'account_item_about_id_card_chevron',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Account', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBody,
                        ),
                      ),
                    ),
                    InkWell(
                      key: Key(item.chevronKey),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => item.destination),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccountItem {
  final String title;
  final Widget destination;
  final String chevronKey;

  const _AccountItem({
    required this.title,
    required this.destination,
    required this.chevronKey,
  });
}
