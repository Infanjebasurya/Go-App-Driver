import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

abstract class AppMapController {
  Future<void> animateTo(LatLng target, {double zoom = 14});
  Future<void> animateToBounds(LatLngBounds bounds, {double padding = 0});
}

class _GoogleMapControllerAdapter implements AppMapController {
  _GoogleMapControllerAdapter(this._controller);

  final gmap.GoogleMapController _controller;

  @override
  Future<void> animateTo(LatLng target, {double zoom = 14}) async {
    await _controller.animateCamera(
      gmap.CameraUpdate.newCameraPosition(
        gmap.CameraPosition(
          target: gmap.LatLng(target.latitude, target.longitude),
          zoom: zoom,
        ),
      ),
    );
  }

  @override
  Future<void> animateToBounds(LatLngBounds bounds, {double padding = 0}) async {
    await _controller.animateCamera(
      gmap.CameraUpdate.newLatLngBounds(
        gmap.LatLngBounds(
          southwest: gmap.LatLng(
            bounds.southwest.latitude,
            bounds.southwest.longitude,
          ),
          northeast: gmap.LatLng(
            bounds.northeast.latitude,
            bounds.northeast.longitude,
          ),
        ),
        padding,
      ),
    );
  }
}

class AppGoogleMap extends StatefulWidget {
  const AppGoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.onMapCreated,
    this.style,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.showTestPlaceholder = true,
    this.isTestOverride,
    this.testPlaceholderText = 'Map disabled in tests',
    this.testPlaceholderKey,
    this.gestureRecognizers,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
    this.compassEnabled = false,
    this.padding,
    this.onTap,
    this.onCameraMove,
    this.onCameraIdle,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final ValueChanged<AppMapController>? onMapCreated;
  final String? style;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool showTestPlaceholder;
  final bool? isTestOverride;
  final String testPlaceholderText;
  final Key? testPlaceholderKey;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  final bool compassEnabled;
  final EdgeInsets? padding;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;

  @override
  State<AppGoogleMap> createState() => _AppGoogleMapState();
}

class _AppGoogleMapState extends State<AppGoogleMap> {
  gmap.GoogleMapController? _controller;
  final Map<String, gmap.BitmapDescriptor> _iconCache =
      <String, gmap.BitmapDescriptor>{};
  final Set<String> _loadingAssetIcons = <String>{};

  bool get _isTest =>
      widget.isTestOverride ?? const bool.fromEnvironment('FLUTTER_TEST');

  @override
  void didUpdateWidget(covariant AppGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTest && widget.showTestPlaceholder) {
      return Center(
        child: Text(
          widget.testPlaceholderText,
          key: widget.testPlaceholderKey,
        ),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return const Center(
        child: Text('Google Map supported on Android/iOS/Web'),
      );
    }

    return gmap.GoogleMap(
      initialCameraPosition: gmap.CameraPosition(
        target: gmap.LatLng(
          widget.initialCameraPosition.target.latitude,
          widget.initialCameraPosition.target.longitude,
        ),
        zoom: widget.initialCameraPosition.zoom,
      ),
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      compassEnabled: widget.compassEnabled,
      style: widget.style,
      padding: widget.padding ?? EdgeInsets.zero,
      gestureRecognizers: widget.gestureRecognizers ?? const {},
      markers: _buildMarkers(),
      polylines: _buildPolylines(),
      onMapCreated: (controller) {
        _controller = controller;
        widget.onMapCreated?.call(_GoogleMapControllerAdapter(controller));
      },
      onTap: widget.onTap == null
          ? null
          : (point) => widget.onTap!(LatLng(point.latitude, point.longitude)),
      onCameraMove: widget.onCameraMove == null
          ? null
          : (camera) => widget.onCameraMove!(
              CameraPosition(
                target: LatLng(
                  camera.target.latitude,
                  camera.target.longitude,
                ),
                zoom: camera.zoom,
              ),
            ),
      onCameraIdle: widget.onCameraIdle,
    );
  }

  Set<gmap.Marker> _buildMarkers() {
    return widget.markers
        .map(
          (marker) => gmap.Marker(
            markerId: gmap.MarkerId(marker.markerId.value),
            position: gmap.LatLng(
              marker.position.latitude,
              marker.position.longitude,
            ),
            icon: _resolveMarkerIcon(marker.icon),
            infoWindow: gmap.InfoWindow(
              title: marker.infoWindow.title,
              snippet: marker.infoWindow.snippet,
            ),
            draggable: marker.draggable,
            onTap: marker.onTap,
            onDragEnd: marker.onDragEnd == null
                ? null
                : (position) => marker.onDragEnd!(
                    LatLng(position.latitude, position.longitude),
                  ),
          ),
        )
        .toSet();
  }

  gmap.BitmapDescriptor _resolveMarkerIcon(BitmapDescriptor? icon) {
    if (icon == null) {
      return gmap.BitmapDescriptor.defaultMarker;
    }

    final String? assetName = icon.assetName;
    if (assetName != null && assetName.isNotEmpty) {
      final String key = 'asset:$assetName';
      final gmap.BitmapDescriptor? cached = _iconCache[key];
      if (cached != null) {
        return cached;
      }
      _loadAssetIcon(assetName, key);
      return gmap.BitmapDescriptor.defaultMarker;
    }

    final double hue = icon.hue ?? 0;
    final String hueKey = 'hue:$hue';
    return _iconCache.putIfAbsent(
      hueKey,
      () => gmap.BitmapDescriptor.defaultMarkerWithHue(hue),
    );
  }

  void _loadAssetIcon(String assetName, String key) {
    if (_loadingAssetIcons.contains(key)) return;
    _loadingAssetIcons.add(key);

    gmap.BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(44, 44)),
      assetName,
    ).then((descriptor) {
      if (!mounted) return;
      setState(() => _iconCache[key] = descriptor);
    }).catchError((_) {}).whenComplete(() {
      _loadingAssetIcons.remove(key);
    });
  }

  Set<gmap.Polyline> _buildPolylines() {
    return widget.polylines
        .map(
          (polyline) => gmap.Polyline(
            polylineId: gmap.PolylineId(polyline.polylineId.value),
            points: polyline.points
                .map((p) => gmap.LatLng(p.latitude, p.longitude))
                .toList(growable: false),
            color: polyline.color,
            width: polyline.width,
          ),
        )
        .toSet();
  }

}
