import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/theme/app_colors.dart';

class MapWidgetController {
  Future<void> Function()? _recenterAction;

  Future<void> recenterToCurrentLocation() async {
    await _recenterAction?.call();
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.controller});

  final MapWidgetController? controller;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const LatLng _fallbackPoint = LatLng(12.9716, 77.5946);

  final MapStyleLoader _styleLoader = const MapStyleLoader();
  AppMapController? _mapController;
  String? _mapStyle;
  LatLng _currentPoint = _fallbackPoint;
  bool _showCaptainArrow = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._recenterAction = _recenter;
    _loadMapStyle();
    _loadCurrentLocation();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._recenterAction = null;
      widget.controller?._recenterAction = _recenter;
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await _styleLoader.loadDefault();
      if (!mounted) return;
      setState(() => _mapStyle = style);
    } catch (_) {}
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final Position? known = await Geolocator.getLastKnownPosition();
      if (known != null && mounted) {
        final knownPoint = LatLng(known.latitude, known.longitude);
        setState(() {
          _currentPoint = knownPoint;
          _showCaptainArrow = true;
        });
        await _mapController?.animateTo(knownPoint, zoom: 16);
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final LatLng point = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _currentPoint = point;
        _showCaptainArrow = true;
      });

      await _mapController?.animateTo(point, zoom: 16);
    } catch (_) {}
  }

  Future<void> _recenter() async {
    await _loadCurrentLocation();
    if (!_showCaptainArrow && mounted) {
      setState(() => _showCaptainArrow = true);
    }
    await _mapController?.animateTo(_currentPoint, zoom: 16);
  }

  @override
  void dispose() {
    widget.controller?._recenterAction = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AppGoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPoint,
            zoom: 14,
          ),
          style: _mapStyle,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            unawaited(_mapController?.animateTo(_currentPoint, zoom: 16));
          },
        ),
        if (_showCaptainArrow)
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/image/bike.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stackTrace) => const Icon(
                Icons.navigation,
                color: AppColors.greenStrong,
                size: 34,
              ),
            ),
          ),
      ],
    );
  }
}
