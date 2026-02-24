import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_NotificationItem> notifications = <_NotificationItem>[
      _NotificationItem(
        title: 'New ride request nearby',
        message: 'A new order is available within 1.2 km of your location.',
        timeLabel: '2 min ago',
        icon: Icons.local_taxi_outlined,
      ),
      _NotificationItem(
        title: 'Trip completed successfully',
        message: 'Your last trip earnings have been added to your wallet.',
        timeLabel: '18 min ago',
        icon: Icons.check_circle_outline,
      ),
      _NotificationItem(
        title: 'Wallet low balance',
        message: 'Top up your wallet to continue receiving priority trips.',
        timeLabel: '1 hr ago',
        icon: Icons.account_balance_wallet_outlined,
      ),
      _NotificationItem(
        title: 'Document reminder',
        message: 'Please verify your pending document to avoid interruptions.',
        timeLabel: 'Yesterday',
        icon: Icons.description_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceF5,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0.8,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.neutral333,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: notifications.isEmpty
            ? const _EmptyNotifications()
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  14 + MediaQuery.of(context).padding.bottom,
                ),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (_, index) =>
                    _NotificationCard(item: notifications[index]),
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceF0,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: AppColors.emerald, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral333,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral666,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.timeLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral888,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppColors.neutralAAA,
            ),
            SizedBox(height: 10),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral555,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'You will see trip, wallet, and account updates here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.neutral888,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
  });

  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
}
