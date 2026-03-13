import 'package:goapp/core/service/location_service.dart';
import 'package:goapp/core/service/permission_service.dart';

enum LocationIssue {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationAccessResult {
  const LocationAccessResult._({required this.isReady, this.issue});

  const LocationAccessResult.ready() : this._(isReady: true);

  const LocationAccessResult.blocked(LocationIssue issue)
    : this._(isReady: false, issue: issue);

  final bool isReady;
  final LocationIssue? issue;
}

class LocationPermissionGuard {
  const LocationPermissionGuard();

  static const LocationService _locationService = LocationService();
  static const PermissionService _permissionService = PermissionService();

  Future<LocationAccessResult> ensureReady({
    bool requestPermission = false,
  }) async {
    AppLocationPermissionStatus permission = await _locationService
        .checkPermission();
    if (permission == AppLocationPermissionStatus.denied && requestPermission) {
      permission = await _locationService.requestPermission();
    }

    if (permission == AppLocationPermissionStatus.denied) {
      return const LocationAccessResult.blocked(LocationIssue.permissionDenied);
    }

    if (permission == AppLocationPermissionStatus.deniedForever) {
      return const LocationAccessResult.blocked(
        LocationIssue.permissionDeniedForever,
      );
    }

    final bool serviceEnabled = await _locationService
        .isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationAccessResult.blocked(LocationIssue.serviceDisabled);
    }

    return const LocationAccessResult.ready();
  }

  Future<bool> openLocationSettings() async {
    final bool opened = await _locationService.openLocationSettings();
    if (opened) return true;
    return _permissionService.openAppSettings();
  }

  Future<bool> openAppSettings() async {
    final bool opened = await _locationService.openAppSettings();
    if (opened) return true;
    return _permissionService.openAppSettings();
  }
}
