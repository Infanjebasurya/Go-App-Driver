import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/service/location_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/location_disabled_banner.dart';
import 'package:goapp/core/di/injection.dart';

class MapWidgetController {
  Future<void> Function()? _recenterAction;
  void Function(LocationIssue? issue)? _locationIssueListener;

  Future<void> recenterToCurrentLocation() async {
    await _recenterAction?.call();
  }

  void bindLocationIssueListener(
    void Function(LocationIssue? issue)? listener,
  ) {
    _locationIssueListener = listener;
  }

  void _notifyLocationIssue(LocationIssue? issue) {
    _locationIssueListener?.call(issue);
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.controller});

  final MapWidgetController? controller;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with WidgetsBindingObserver {
  static const LatLng _fallbackPoint = LatLng(12.9716, 77.5946);

  final MapStyleLoader _styleLoader = const MapStyleLoader();
  late final LocationPermissionGuard _locationGuard;
  late final LocationService _locationService;
  AppMapController? _mapController;
  String? _mapStyle;
  LatLng _currentPoint = _fallbackPoint;
  bool _showCaptainArrow = false;
  LocationIssue? _locationIssue;

  @override
  void initState() {
    super.initState();
    _locationGuard = sl<LocationPermissionGuard>();
    _locationService = sl<LocationService>();
    WidgetsBinding.instance.addObserver(this);
    widget.controller?._recenterAction = _recenter;
    widget.controller?._notifyLocationIssue(_locationIssue);
    _loadMapStyle();
    _loadCurrentLocation();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._recenterAction = null;
      oldWidget.controller?.bindLocationIssueListener(null);
      widget.controller?._recenterAction = _recenter;
      widget.controller?._notifyLocationIssue(_locationIssue);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshLocationState());
    }
  }

  Future<void> _refreshLocationState() async {
    final result = await _locationGuard.ensureReady(requestPermission: false);
    if (!mounted) return;
    setState(() => _locationIssue = result.issue);
    widget.controller?._notifyLocationIssue(_locationIssue);
    if (result.isReady) {
      unawaited(_loadCurrentLocation(requestPermission: false));
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await _styleLoader.loadBooking();
      if (!mounted) return;
      setState(() => _mapStyle = style);
    } catch (_) {}
  }

  Future<void> _loadCurrentLocation({bool requestPermission = true}) async {
    try {
      final result = await _locationGuard.ensureReady(
        requestPermission: requestPermission,
      );
      if (!mounted) return;
      setState(() => _locationIssue = result.issue);
      widget.controller?._notifyLocationIssue(_locationIssue);
      if (!result.isReady) {
        return;
      }

      final AppLocationPosition? known = await _locationService.getLastKnownPosition();
      if (known != null && mounted) {
        final knownPoint = LatLng(known.latitude, known.longitude);
        setState(() {
          _currentPoint = knownPoint;
          _showCaptainArrow = true;
        });
        await _mapController?.animateTo(knownPoint, zoom: 16);
      }

      final AppLocationPosition position = await _locationService
          .getCurrentPosition(timeLimit: const Duration(seconds: 8));

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

  Future<void> _onLocationBannerActionTap() async {
    final issue = _locationIssue;
    if (issue == null) return;
    if (issue == LocationIssue.serviceDisabled) {
      await _locationGuard.openLocationSettings();
    } else {
      await _locationGuard.openAppSettings();
    }
    if (!mounted) return;
    unawaited(_refreshLocationState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller?._recenterAction = null;
    widget.controller?.bindLocationIssueListener(null);
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
        if (_locationIssue != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: LocationDisabledBanner(
              issue: _locationIssue!,
              onActionTap: _onLocationBannerActionTap,
            ),
          ),
      ],
    );
  }
}



