import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';

class AppNotificationEntry {
  const AppNotificationEntry({
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String title;
  final String message;
  final DateTime createdAt;
}

class NotificationsFeed {
  NotificationsFeed._();

  static final ValueNotifier<List<AppNotificationEntry>> notifier =
      ValueNotifier<List<AppNotificationEntry>>(<AppNotificationEntry>[
        AppNotificationEntry(
          title: 'New ride request nearby',
          message: 'A new order is available within 1.2 km of your location.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        AppNotificationEntry(
          title: 'Trip completed successfully',
          message: 'Your last trip earnings have been added to your wallet.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        ),
        AppNotificationEntry(
          title: 'Wallet low balance',
          message: 'Top up your wallet to continue receiving priority trips.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ]);

  static void add({
    required String title,
    required String message,
    bool pushToDevice = true,
  }) {
    final AppNotificationEntry entry = AppNotificationEntry(
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
    notifier.value = <AppNotificationEntry>[entry, ...notifier.value];
    if (pushToDevice) {
      unawaited(LocalNotificationService.show(title: title, body: message));
    }
  }
}
