import 'package:flutter/services.dart';

import 'network_settings_service.dart';

class NetworkSettingsServiceImpl implements NetworkSettingsService {
  static const MethodChannel _channel = MethodChannel('native_permissions');

  @override
  Future<bool> openWifiSettings() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return true;
    }
    final bool? result = await _channel.invokeMethod<bool>('openWifiSettings');
    return result ?? false;
  }

  @override
  Future<bool> openMobileDataSettings() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return true;
    }
    final bool? result = await _channel.invokeMethod<bool>(
      'openMobileDataSettings',
    );
    return result ?? false;
  }
}
