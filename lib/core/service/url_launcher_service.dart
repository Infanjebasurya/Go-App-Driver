import 'package:flutter/services.dart';

enum AppLaunchMode { externalApplication }

class UrlLauncherService {
  const UrlLauncherService();

  static const MethodChannel _channel = MethodChannel(
    'app/url_launcher_service',
  );

  Future<bool> canLaunch(String url) async {
    return await _channel.invokeMethod<bool>('canLaunch', <String, Object>{
          'url': url,
        }) ??
        false;
  }

  Future<bool> launch(
    String url, {
    AppLaunchMode mode = AppLaunchMode.externalApplication,
  }) async {
    return await _channel.invokeMethod<bool>('launch', <String, Object>{
          'url': url,
          'mode': mode.name,
        }) ??
        false;
  }
}
