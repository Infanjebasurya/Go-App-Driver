import 'package:flutter/services.dart';

enum AppPermission {
  camera,
  photos,
  notification,
}

enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  provisional,
}

class PermissionService {
  static const MethodChannel _channel = MethodChannel('app/permission_service');

  const PermissionService();

  Future<AppPermissionStatus> status(AppPermission permission) async {
    final String? status = await _channel.invokeMethod<String>(
      'status',
      <String, String>{'permission': permission.name},
    );
    return _mapStatus(status);
  }

  Future<AppPermissionStatus> request(AppPermission permission) async {
    final String? status = await _channel.invokeMethod<String>(
      'request',
      <String, String>{'permission': permission.name},
    );
    return _mapStatus(status);
  }

  Future<bool> openAppSettings() async {
    return await _channel.invokeMethod<bool>('openAppSettings') ?? false;
  }

  AppPermissionStatus _mapStatus(String? status) {
    return switch (status) {
      'granted' => AppPermissionStatus.granted,
      'permanentlyDenied' => AppPermissionStatus.permanentlyDenied,
      'restricted' => AppPermissionStatus.restricted,
      'limited' => AppPermissionStatus.limited,
      'provisional' => AppPermissionStatus.provisional,
      _ => AppPermissionStatus.denied,
    };
  }
}
