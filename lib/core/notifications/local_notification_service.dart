import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static const String _channelId = 'ride_updates';
  static const String _channelName = 'Ride Updates';
  static const String _channelDescription =
      'Notifications for ride flow milestones and rider updates.';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static int _idCounter = 1000;

  static Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);

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

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(id ?? _idCounter++, title, body, details);
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

    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: false,
        showProgress: true,
        maxProgress: safeMax,
        progress: safeProgress,
        ongoing: ongoing,
        onlyAlertOnce: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );

    await _plugin.show(id, title, body, details);
  }
}
