import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionHelper {
  NotificationPermissionHelper._();

  static bool _requested = false;

  static Future<void> ensureRequestedOnce() async {
    if (_requested) return;
    if (kIsWeb) return;
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    _requested = true;
    try {
      final PermissionStatus status = await Permission.notification.status;
      if (status.isGranted || status.isPermanentlyDenied) return;
      await Permission.notification.request();
    } catch (_) {}
  }
}
