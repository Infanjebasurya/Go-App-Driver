import 'package:flutter/material.dart';
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

  static Future<void> ensureRequestedOnceWithPrompt(
    BuildContext context,
  ) async {
    if (_requested) return;
    if (kIsWeb) return;
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    _requested = true;
    try {
      final PermissionStatus status = await Permission.notification.status;
      if (status.isGranted) return;
      if (!context.mounted) return;

      if (status.isPermanentlyDenied) {
        await _showEnableSettingsDialog(context);
        return;
      }

      final bool allow = await _showPrePermissionDialog(context);
      if (!allow || !context.mounted) return;
      await Permission.notification.request();
    } catch (_) {}
  }

  static Future<bool> _showPrePermissionDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF0C9B61),
              ),
              SizedBox(width: 8),
              Expanded(child: Text('Enable Notifications')),
            ],
          ),
          content: const Text(
            'Get instant ride updates, trip alerts, and important account messages.',
            style: TextStyle(height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0C9B61),
              ),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static Future<void> _showEnableSettingsDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Notifications Blocked'),
          content: const Text(
            'Notification access is disabled for this app. Open settings to enable it.',
            style: TextStyle(height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openAppSettings();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0C9B61),
              ),
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
  }
}
