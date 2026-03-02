import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goapp/core/storage/home_trip_resume_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/features/notifications/presentation/model/notifications_feed.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    if (Env.mockApi) {
      unawaited(HomeTripResumeStore.markForceHomeOnNextLaunch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceF5,
      appBar: AppAppBar(
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
        child: ValueListenableBuilder<List<AppNotificationEntry>>(
          valueListenable: NotificationsFeed.notifier,
          builder: (context, notifications, _) {
            if (notifications.isEmpty) {
              return const _EmptyNotifications();
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                14,
                14,
                14,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (_, index) =>
                  _NotificationCard(item: notifications[index]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final AppNotificationEntry item;

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
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.emerald,
              size: 21,
            ),
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
                  _formatTime(item.createdAt),
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

  String _formatTime(DateTime createdAt) {
    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
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

