import 'package:flutter/services.dart';

class VibrationService {
  static const MethodChannel _channel = MethodChannel('app/vibration_service');

  const VibrationService();

  Future<void> vibrateAlert() async {
    try {
      await _channel.invokeMethod<void>('vibrateAlert');
    } catch (_) {}
  }
}
