import 'package:flutter/material.dart';

@immutable
class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) {
    return other is LatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

@immutable
class LatLngBounds {
  const LatLngBounds({required this.southwest, required this.northeast});

  final LatLng southwest;
  final LatLng northeast;
}

@immutable
class CameraPosition {
  const CameraPosition({required this.target, required this.zoom});

  final LatLng target;
  final double zoom;
}

@immutable
class MarkerId {
  const MarkerId(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is MarkerId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

@immutable
class PolylineId {
  const PolylineId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PolylineId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

@immutable
class InfoWindow {
  const InfoWindow({this.title, this.snippet});

  final String? title;
  final String? snippet;
}

@immutable
class BitmapDescriptor {
  const BitmapDescriptor._({this.hue, this.assetName});

  final double? hue;
  final String? assetName;

  static const double hueRed = 0.0;
  static const double hueGreen = 120.0;
  static const double hueAzure = 210.0;
  static const double hueYellow = 60.0;
  static const double hueOrange = 30.0;

  static BitmapDescriptor defaultMarkerWithHue(double hue) {
    return BitmapDescriptor._(hue: hue);
  }

  static Future<BitmapDescriptor> asset(
    ImageConfiguration configuration,
    String assetName,
  ) async {
    return BitmapDescriptor._(assetName: assetName);
  }
}

@immutable
class Marker {
  const Marker({
    required this.markerId,
    required this.position,
    this.icon,
    this.infoWindow = const InfoWindow(),
    this.draggable = false,
    this.onDragEnd,
    this.onTap,
  });

  final MarkerId markerId;
  final LatLng position;
  final BitmapDescriptor? icon;
  final InfoWindow infoWindow;
  final bool draggable;
  final ValueChanged<LatLng>? onDragEnd;
  final VoidCallback? onTap;

  @override
  bool operator ==(Object other) =>
      other is Marker && other.markerId == markerId;

  @override
  int get hashCode => markerId.hashCode;
}

@immutable
class Polyline {
  const Polyline({
    required this.polylineId,
    required this.points,
    this.color = const Color(0xFF08B56F),
    this.width = 4,
  });

  final PolylineId polylineId;
  final List<LatLng> points;
  final Color color;
  final int width;

  @override
  bool operator ==(Object other) =>
      other is Polyline && other.polylineId == polylineId;

  @override
  int get hashCode => polylineId.hashCode;
}
