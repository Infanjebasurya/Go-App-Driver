import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_accident_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_customer_issue_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_traffic_challan_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_vehicle_seized_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _EmergencyItem.items;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Emergency', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: const HelpSupportAppBarBottomDivider(),
      ),
      bottomNavigationBar: const HelpTicketTrackingFooter(),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(
          height: 0,
          thickness: 0.5,
          color: AppColors.handleGray.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return HelpSupportChevronOnlyListItem(
            title: item.title,
            chevronKey: item.chevronKey,
            onChevronTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => item.destination));
            },
          );
        },
      ),
    );
  }
}

class _EmergencyItem {
  const _EmergencyItem({
    required this.title,
    required this.destination,
    required this.chevronKey,
  });

  final String title;
  final Widget destination;
  final String chevronKey;

  static const List<_EmergencyItem> items = [
    _EmergencyItem(
      title: 'I had an accident',
      destination: EmergencyAccidentScreen(),
      chevronKey: 'emergency_item_accident_chevron',
    ),
    _EmergencyItem(
      title: 'I had an issue with a customer',
      destination: EmergencyCustomerIssueScreen(),
      chevronKey: 'emergency_item_customer_issue_chevron',
    ),
    _EmergencyItem(
      title: 'My vehicle was seized by authorities',
      destination: EmergencyVehicleSeizedScreen(),
      chevronKey: 'emergency_item_vehicle_seized_chevron',
    ),
    _EmergencyItem(
      title: 'I received a traffic challan',
      destination: EmergencyTrafficChallanScreen(),
      chevronKey: 'emergency_item_traffic_challan_chevron',
    ),
  ];
}
