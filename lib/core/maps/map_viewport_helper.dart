import 'package:goapp/core/maps/map_types.dart';

import 'map_view_mode.dart';

class MapViewportHelper {
  const MapViewportHelper._();

  static LatLngBounds boundsFor({
    required LatLng pickup,
    required LatLng drop,
  }) {
    final swLat = pickup.latitude < drop.latitude
        ? pickup.latitude
        : drop.latitude;
    final swLng = pickup.longitude < drop.longitude
        ? pickup.longitude
        : drop.longitude;
    final neLat = pickup.latitude > drop.latitude
        ? pickup.latitude
        : drop.latitude;
    final neLng = pickup.longitude > drop.longitude
        ? pickup.longitude
        : drop.longitude;
    return LatLngBounds(
      southwest: LatLng(swLat, swLng),
      northeast: LatLng(neLat, neLng),
    );
  }

  static LatLng? targetFor({
    required MapViewMode mode,
    LatLng? pickup,
    LatLng? drop,
  }) {
    switch (mode) {
      case MapViewMode.pickup:
        return pickup ?? drop;
      case MapViewMode.drop:
        return drop ?? pickup;
      case MapViewMode.both:
        return null;
    }
  }
}
