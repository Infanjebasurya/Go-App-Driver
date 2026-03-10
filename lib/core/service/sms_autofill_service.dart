import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

/// Base State wrapper so feature code doesn't import `sms_autofill` directly.
abstract class SmsAutoFillState<T extends StatefulWidget> extends State<T>
    with CodeAutoFill {
  @protected
  void startSmsCodeListener() {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;
    listenForCode();
  }

  @protected
  void stopSmsCodeListener() {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;
    cancel();
  }
}
