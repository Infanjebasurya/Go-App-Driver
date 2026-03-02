import 'package:flutter/material.dart';

abstract final class SnackBarUtils {
  static const Duration defaultDuration = Duration(seconds: 2);

  static void show(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    Color? backgroundColor,
    SnackBarBehavior? behavior,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    behavior ??= SnackBarBehavior.floating;
    if (margin != null && behavior == SnackBarBehavior.fixed) {
      margin = null;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: behavior,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
  }) {
    show(
      context,
      message,
      duration: duration,
      backgroundColor: const Color(0xFFE53935),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}
