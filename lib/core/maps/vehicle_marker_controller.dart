import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:goapp/core/maps/map_types.dart';

import 'vehicle_icon_loader.dart';

class VehicleMarkerController {
  VehicleMarkerController({
    required this.onUpdate,
    this.animate = true,
    this.bikes = 6,
    this.autos = 6,
    this.cars = 6,
    this.radiusMeters = 800,
    this.tick = const Duration(milliseconds: 500),
    this.driftMinMeters = 2,
    this.driftMaxMeters = 6,
    BitmapDescriptor? bikeIcon,
    BitmapDescriptor? autoIcon,
    BitmapDescriptor? carIcon,
  }) : _bikeIcon = bikeIcon,
       _autoIcon = autoIcon,
       _carIcon = carIcon;

  final VoidCallback onUpdate;
  final bool animate;
  final int bikes;
  final int autos;
  final int cars;
  final double radiusMeters;
  final Duration tick;
  final double driftMinMeters;
  final double driftMaxMeters;

  Timer? _timer;
  LatLng? _center;
  final List<_VehicleMarker> _vehicles = [];
  bool _paused = false;
  BitmapDescriptor? _bikeIcon;
  BitmapDescriptor? _autoIcon;
  BitmapDescriptor? _carIcon;

  LatLng? get center => _center;
  bool get isAnimating => _timer?.isActive == true;

  void setIcons({
    BitmapDescriptor? bikeIcon,
    BitmapDescriptor? autoIcon,
    BitmapDescriptor? carIcon,
  }) {
    _bikeIcon = bikeIcon ?? _bikeIcon;
    _autoIcon = autoIcon ?? _autoIcon;
    _carIcon = carIcon ?? _carIcon;
    if (_center != null) {
      _seedVehicles(_center!);
      onUpdate();
    }
  }

  Future<void> loadBikeIcon({Size size = const Size(36, 36)}) async {
    final icon = await VehicleIconLoader.loadBikeIcon(size: size);
    setIcons(bikeIcon: icon);
  }

  Set<Marker> get markers {
    final Set<Marker> markers = {};
    for (final vehicle in _vehicles) {
      markers.add(
        Marker(
          markerId: MarkerId(vehicle.id),
          position: vehicle.position,
          icon: vehicle.icon,
          infoWindow: InfoWindow(title: vehicle.type),
        ),
      );
    }
    return markers;
  }

  void start(LatLng center) {
    _center = center;
    _seedVehicles(center);
    _timer?.cancel();
    _paused = false;
    if (!animate) return;
    _timer = Timer.periodic(tick, (_) {
      _moveVehicles();
      onUpdate();
    });
  }

  void pause() {
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  void resume() {
    if (!animate || _paused == false) return;
    if (_center == null) return;
    _paused = false;
    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) {
      _moveVehicles();
      onUpdate();
    });
  }

  void handleLifecycle(AppLifecycleState state) {
    if (!animate) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      pause();
    } else if (state == AppLifecycleState.resumed) {
      resume();
    }
  }

  void stop({bool notify = true}) {
    final hadVehicles = _vehicles.isNotEmpty;
    _timer?.cancel();
    _timer = null;
    _center = null;
    _vehicles.clear();
    _paused = false;
    if (notify && hadVehicles) {
      onUpdate();
    }
  }

  void dispose() {
    _timer?.cancel();
  }

  void _seedVehicles(LatLng center) {
    final int seed =
        (center.latitude * 1e6).round() ^ (center.longitude * 1e6).round();
    final rand = math.Random(seed);

    _vehicles.clear();

    _VehicleMarker buildVehicle(String type, int index, BitmapDescriptor icon) {
      final double distance = math.sqrt(rand.nextDouble()) * radiusMeters;
      final double bearing = rand.nextDouble() * 2 * math.pi;
      final LatLng pos = _offsetPoint(center, distance, bearing);
      final double drift =
          driftMinMeters +
          rand.nextDouble() * (driftMaxMeters - driftMinMeters);
      final double driftBearing = rand.nextDouble() * 2 * math.pi;
      return _VehicleMarker(
        id: '${type}_$index',
        type: type,
        position: pos,
        icon: icon,
        driftMeters: drift,
        driftBearing: driftBearing,
      );
    }

    for (int i = 0; i < bikes; i++) {
      _vehicles.add(
        buildVehicle(
          'Bike',
          i,
          _bikeIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    for (int i = 0; i < autos; i++) {
      _vehicles.add(
        buildVehicle(
          'Auto',
          i,
          _autoIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );
    }
    for (int i = 0; i < cars; i++) {
      _vehicles.add(
        buildVehicle(
          'Car',
          i,
          _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }
  }

  void _moveVehicles() {
    final center = _center;
    if (center == null) return;
    final rand = math.Random();
    for (final vehicle in _vehicles) {
      final LatLng next = _offsetPoint(
        vehicle.position,
        vehicle.driftMeters,
        vehicle.driftBearing,
      );
      final double distanceFromCenter = _distanceMeters(center, next);
      if (distanceFromCenter > radiusMeters) {
        vehicle.driftBearing = vehicle.driftBearing + math.pi;
      } else {
        vehicle.position = next;
      }
      vehicle.driftBearing =
          vehicle.driftBearing + (rand.nextDouble() - 0.5) * 0.2;
    }
  }

  LatLng _offsetPoint(LatLng start, double distanceMeters, double bearingRad) {
    const double earthRadius = 6371000;
    final double lat1 = start.latitude * math.pi / 180;
    final double lon1 = start.longitude * math.pi / 180;
    final double angDist = distanceMeters / earthRadius;

    final double lat2 = math.asin(
      math.sin(lat1) * math.cos(angDist) +
          math.cos(lat1) * math.sin(angDist) * math.cos(bearingRad),
    );
    final double lon2 =
        lon1 +
        math.atan2(
          math.sin(bearingRad) * math.sin(angDist) * math.cos(lat1),
          math.cos(angDist) - math.sin(lat1) * math.sin(lat2),
        );

    return LatLng(lat2 * 180 / math.pi, lon2 * 180 / math.pi);
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const double earthRadius = 6371000;
    final double dLat = (b.latitude - a.latitude) * math.pi / 180;
    final double dLon = (b.longitude - a.longitude) * math.pi / 180;
    final double lat1 = a.latitude * math.pi / 180;
    final double lat2 = b.latitude * math.pi / 180;
    final double h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadius * c;
  }
}

class _VehicleMarker {
  final String id;
  final String type;
  LatLng position;
  final BitmapDescriptor icon;
  final double driftMeters;
  double driftBearing;

  _VehicleMarker({
    required this.id,
    required this.type,
    required this.position,
    required this.icon,
    required this.driftMeters,
    required this.driftBearing,
  });
}
