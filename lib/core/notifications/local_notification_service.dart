import 'package:goapp/core/service/notification_service.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static Future<void> initialize() async {
    await NotificationService.initialize();
  }

  static Future<void> show({
    int? id,
    required String title,
    required String body,
  }) async {
    await NotificationService.show(id: id, title: title, body: body);
  }

  static Future<void> showProgress({
    required int id,
    required String title,
    required String body,
    required int progress,
    int maxProgress = 100,
    bool ongoing = true,
  }) async {
    await NotificationService.showProgress(
      id: id,
      title: title,
      body: body,
      progress: progress,
      maxProgress: maxProgress,
      ongoing: ongoing,
    );
  }
}
