import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/pages/app_issue_detail_screens.dart';
import 'package:goapp/features/help_support/presentation/pages/ticket_tracking_screen.dart';

class NewAppIssueScreen extends StatelessWidget {
  const NewAppIssueScreen({super.key});

  static const List<_AppIssueItem> _items = <_AppIssueItem>[
    _AppIssueItem(
      title: 'Unable to go on duty',
      destination: UnableToGoOnDutyScreen(),
      chevronKey: 'app_issue_unable_go_duty_chevron',
    ),
    _AppIssueItem(
      title: 'Not receiving orders',
      destination: NotReceivingOrdersScreen(),
      chevronKey: 'app_issue_not_receiving_orders_chevron',
    ),
    _AppIssueItem(
      title: 'Service suspended on my account',
      destination: ServiceSuspendedScreen(),
      chevronKey: 'app_issue_service_suspended_chevron',
    ),
    _AppIssueItem(
      title: 'App is crashing',
      destination: AppCrashingScreen(),
      chevronKey: 'app_issue_app_crashing_chevron',
    ),
    _AppIssueItem(
      title: 'Change my mobile number',
      destination: ChangeMobileNumberScreen(),
      chevronKey: 'app_issue_change_mobile_chevron',
    ),
    _AppIssueItem(
      title: 'Update my vehicle details',
      destination: UpdateVehicleDetailsScreen(),
      chevronKey: 'app_issue_update_vehicle_details_chevron',
    ),
    _AppIssueItem(
      title: 'Unable to upload documents',
      destination: UnableToUploadDocumentsScreen(),
      chevronKey: 'app_issue_unable_upload_documents_chevron',
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
        title: const Text('App issues', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 44,
                  child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TicketTrackingScreen(),
                      ),
                    );
                  },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textBody,
                      side: const BorderSide(color: AppColors.borderSoft),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Ticket Tracking'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Our support team typically responds within 15 minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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

class _AppIssueItem {
  final String title;
  final Widget destination;
  final String chevronKey;

  const _AppIssueItem({
    required this.title,
    required this.destination,
    required this.chevronKey,
  });
}

