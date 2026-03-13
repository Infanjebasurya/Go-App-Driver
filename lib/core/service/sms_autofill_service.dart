import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Base State wrapper so feature code doesn't import `sms_autofill` directly.
abstract class SmsAutoFillState<T extends StatefulWidget> extends State<T> {
  static const MethodChannel _methodChannel = MethodChannel(
    'app/sms_autofill_service',
  );
  static const EventChannel _eventChannel = EventChannel(
    'app/sms_autofill_events',
  );

  StreamSubscription<Object?>? _subscription;

  @protected
  String? code;

  @protected
  void codeUpdated();

  @protected
  void startSmsCodeListener() {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      final String next = (event as String?)?.trim() ?? '';
      if (next.isEmpty) return;
      code = next;
      codeUpdated();
    });
    _methodChannel.invokeMethod<void>('start');
  }

  @protected
  void stopSmsCodeListener() {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;
    _subscription?.cancel();
    _subscription = null;
    _methodChannel.invokeMethod<void>('stop');
  }
}
