import 'package:flutter/services.dart';

class AppBackgroundServiceClient {
  const AppBackgroundServiceClient();

  static const MethodChannel _channel = MethodChannel('app/background_service');

  Future<bool> isRunning() async {
    return await _channel.invokeMethod<bool>('isRunning') ?? false;
  }

  Future<void> startService() {
    return _channel.invokeMethod<void>('startService');
  }

  Future<void> invoke(String event, [Map<String, dynamic>? data]) {
    return _channel.invokeMethod<void>('invoke', <String, Object?>{
      'event': event,
      'data': data,
    });
  }
}

class BackgroundService {
  BackgroundService._();

  static const AppBackgroundServiceClient instance =
      AppBackgroundServiceClient();
  static const String startTripEvent = 'start_trip';
  static const String stopTripEvent = 'stop_trip';
  static const int serviceNotificationId = 4101;

  static Future<void> configure() {
    return AppBackgroundServiceClient._channel.invokeMethod<void>('configure');
  }
}
