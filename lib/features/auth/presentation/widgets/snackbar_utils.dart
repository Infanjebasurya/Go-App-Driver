import 'package:flutter/material.dart';

abstract final class SnackBarUtils {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 12 + keyboardInset),
      ),
    );
  }
}
