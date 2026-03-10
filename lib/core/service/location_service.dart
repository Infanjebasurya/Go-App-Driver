import 'package:flutter/services.dart';

enum AppLocationPermissionStatus {
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
}

class AppLocationPosition {
  const AppLocationPosition({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class LocationService {
  static const MethodChannel _channel = MethodChannel('app/location_service');

  const LocationService();

  Future<AppLocationPermissionStatus> checkPermission() async {
    final String? permission = await _channel.invokeMethod<String>(
      'checkPermission',
    );
    return _mapPermission(permission);
  }

  Future<AppLocationPermissionStatus> requestPermission() async {
    final String? permission = await _channel.invokeMethod<String>(
      'requestPermission',
    );
    return _mapPermission(permission);
  }

  Future<bool> isLocationServiceEnabled() async {
    return await _channel.invokeMethod<bool>('isLocationServiceEnabled') ??
        false;
  }

  Future<bool> openLocationSettings() async {
    return await _channel.invokeMethod<bool>('openLocationSettings') ?? false;
  }

  Future<bool> openAppSettings() async {
    return await _channel.invokeMethod<bool>('openAppSettings') ?? false;
  }

  Future<AppLocationPosition?> getLastKnownPosition() async {
    final Map<Object?, Object?>? position =
        await _channel.invokeMethod<Map<Object?, Object?>>('getLastKnownPosition');
    return _mapPosition(position);
  }

  Future<AppLocationPosition> getCurrentPosition({
    Duration timeLimit = const Duration(seconds: 8),
  }) async {
    final Map<Object?, Object?>? position =
        await _channel.invokeMethod<Map<Object?, Object?>>(
      'getCurrentPosition',
      <String, int>{'timeLimitMs': timeLimit.inMilliseconds},
    );
    final AppLocationPosition? mapped = _mapPosition(position);
    if (mapped == null) {
      throw PlatformException(
        code: 'location_unavailable',
        message: 'Current location is unavailable.',
      );
    }
    return mapped;
  }

  AppLocationPermissionStatus _mapPermission(String? permission) {
    return switch (permission) {
      'deniedForever' => AppLocationPermissionStatus.deniedForever,
      'whileInUse' => AppLocationPermissionStatus.whileInUse,
      'always' => AppLocationPermissionStatus.always,
      'unableToDetermine' => AppLocationPermissionStatus.unableToDetermine,
      _ => AppLocationPermissionStatus.denied,
    };
  }

  AppLocationPosition? _mapPosition(Map<Object?, Object?>? position) {
    if (position == null) return null;
    final double? latitude = (position['latitude'] as num?)?.toDouble();
    final double? longitude = (position['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;
    return AppLocationPosition(latitude: latitude, longitude: longitude);
  }
}
