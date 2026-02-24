import 'package:geolocator/geolocator.dart';

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

  Future<LocationAccessResult> ensureReady({
    bool requestPermission = false,
  }) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationAccessResult.blocked(LocationIssue.serviceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationAccessResult.blocked(LocationIssue.permissionDenied);
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationAccessResult.blocked(
        LocationIssue.permissionDeniedForever,
      );
    }

    return const LocationAccessResult.ready();
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
