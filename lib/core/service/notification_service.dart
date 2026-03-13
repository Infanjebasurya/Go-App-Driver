import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel(
    'app/notification_service',
  );

  NotificationService._();

  static const String channelId = 'ride_updates';
  static const String channelName = 'Ride Updates';
  static const String channelDescription =
      'Notifications for ride flow milestones and rider updates.';

  static bool _initialized = false;
  static int _idCounter = 1000;

  static Future<void> initialize() async {
    if (_initialized) return;
    await _channel.invokeMethod<void>('initialize', <String, String>{
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
    });
    _initialized = true;
  }

  static Future<void> show({
    int? id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    await _channel.invokeMethod<void>('show', <String, Object>{
      'id': id ?? _idCounter++,
      'title': title,
      'body': body,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
    });
  }

  static Future<void> showProgress({
    required int id,
    required String title,
    required String body,
    required int progress,
    int maxProgress = 100,
    bool ongoing = true,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final int safeMax = maxProgress <= 0 ? 100 : maxProgress;
    final int safeProgress = progress.clamp(0, safeMax);

    await _channel.invokeMethod<void>('showProgress', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'progress': safeProgress,
      'maxProgress': safeMax,
      'ongoing': ongoing,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
    });
  }
}
