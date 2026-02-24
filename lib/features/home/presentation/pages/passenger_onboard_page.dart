import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/core/widgets/location_disabled_banner.dart';
import 'package:goapp/features/home/presentation/pages/trip_navigation_page.dart';

class PassengerOnboardPage extends StatefulWidget {
  const PassengerOnboardPage({super.key});

  @override
  State<PassengerOnboardPage> createState() => _PassengerOnboardPageState();
}

class _PassengerOnboardPageState extends State<PassengerOnboardPage>
    with WidgetsBindingObserver {
  static const LatLng _centerPoint = LatLng(13.0696, 80.2154);
  static const LatLng _pickupPoint = LatLng(13.0696, 80.2154);
  static const LatLng _dropPoint = LatLng(13.0744, 80.2241);
  final MapStyleLoader _styleLoader = const MapStyleLoader();
  final LocationPermissionGuard _locationGuard =
      const LocationPermissionGuard();
  final DirectionsRouteService _directionsRouteService =
      DirectionsRouteService();
  String? _mapStyle;
  List<LatLng> _routePoints = const <LatLng>[];
  AppMapController? _mapController;
  LocationIssue? _locationIssue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyle();
    _loadRoute();
    unawaited(_refreshLocationState(requestPermission: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshLocationState());
    }
  }

  Future<void> _refreshLocationState({bool requestPermission = false}) async {
    final result = await _locationGuard.ensureReady(
      requestPermission: requestPermission,
    );
    if (!mounted) return;
    setState(() => _locationIssue = result.issue);
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await _styleLoader.loadBooking();
      if (!mounted) return;
      setState(() => _mapStyle = style);
    } catch (_) {}
  }

  Future<void> _loadRoute() async {
    final route = await _directionsRouteService.fetchDrivingRoute(
      origin: _pickupPoint,
      destination: _dropPoint,
      apiKey: Env.googleMapsApiKey,
      preferDetailedSteps: true,
    );
    if (!mounted) return;
    setState(() {
      _routePoints = route == null || route.length < 2
          ? <LatLng>[_pickupPoint, _dropPoint]
          : route;
    });
    await _focusRouteInView();
  }

  Future<void> _focusRouteInView() async {
    final controller = _mapController;
    if (controller == null) return;
    final minLat = _pickupPoint.latitude < _dropPoint.latitude
        ? _pickupPoint.latitude
        : _dropPoint.latitude;
    final maxLat = _pickupPoint.latitude > _dropPoint.latitude
        ? _pickupPoint.latitude
        : _dropPoint.latitude;
    final minLng = _pickupPoint.longitude < _dropPoint.longitude
        ? _pickupPoint.longitude
        : _dropPoint.longitude;
    final maxLng = _pickupPoint.longitude > _dropPoint.longitude
        ? _pickupPoint.longitude
        : _dropPoint.longitude;
    const pad = 0.0012;
    await controller.animateToBounds(
      LatLngBounds(
        southwest: LatLng(minLat - pad, minLng - pad),
        northeast: LatLng(maxLat + pad, maxLng + pad),
      ),
      padding: 64,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AppGoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _centerPoint,
                zoom: 15,
              ),
              style: _mapStyle,
              markers: <Marker>{
                Marker(
                  markerId: const MarkerId('pickup_marker'),
                  position: _pickupPoint,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: const InfoWindow(title: 'Pickup'),
                ),
                Marker(
                  markerId: const MarkerId('drop_marker'),
                  position: _dropPoint,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: const InfoWindow(title: 'Drop'),
                ),
              },
              polylines: <Polyline>{
                if (_routePoints.length > 1)
                  Polyline(
                    polylineId: const PolylineId('pickup_to_drop_route'),
                    points: _routePoints,
                    color: AppColors.emerald,
                    width: 5,
                  ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                unawaited(_focusRouteInView());
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 120,
            right: 82,
            child: const Icon(
              Icons.location_pin,
              size: 34,
              color: Color(0xFFE91E63),
            ),
          ),
          const Align(alignment: Alignment(0, 0.36), child: _MapCenterMarker()),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 254,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.my_location, color: AppColors.neutral666),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.neutralCCC,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Passenger Onboard',
                      style: TextStyle(
                        fontSize: 46 / 2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral333,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/image/profile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Yogesh S',
                      style: TextStyle(
                        fontSize: 33 / 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral333,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.star, size: 15, color: AppColors.starYellow),
                        SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral666,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Verified & Secure. Ready to begin your journey.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral666,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TripNavigationPage(
                                initialRoutePath: _routePoints.length > 1
                                    ? List<LatLng>.from(_routePoints)
                                    : null,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Start Trip Navigation',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceF5,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: AppColors.neutral666,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Destination',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral666,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '13, vinobaji St, KamarajarNag...',
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutral555,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCenterMarker extends StatelessWidget {
  const _MapCenterMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: Color(0x3325C59A),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.emerald,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.navigation, size: 14, color: AppColors.white),
        ),
      ],
    );
  }
}
