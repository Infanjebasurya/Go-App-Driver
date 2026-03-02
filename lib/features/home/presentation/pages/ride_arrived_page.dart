import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goapp/core/permissions/notification_permission_helper.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/app_assets.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/core/widgets/location_disabled_banner.dart';
import 'package:goapp/core/background/trip_background_service.dart';
import 'package:goapp/features/home/presentation/pages/enter_ride_code_page.dart';
import 'package:goapp/features/notifications/presentation/model/notifications_feed.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

part 'ride_arrived_page_sections.dart';
part 'ride_arrived_page_state_extensions.dart';

class RideArrivedPage extends StatefulWidget {
  const RideArrivedPage({
    super.key,
    this.pickupPoint = const LatLng(13.0696, 80.2154),
    this.dropPoint = const LatLng(13.0744, 80.2241),
  });

  final LatLng pickupPoint;
  final LatLng dropPoint;

  @override
  State<RideArrivedPage> createState() => _RideArrivedPageState();
}

class _RideArrivedPageState extends State<RideArrivedPage>
    with WidgetsBindingObserver {
  static const LatLng _fallbackDriverPoint = LatLng(13.0624, 80.2098);
  static const Duration _routeTravelDuration = Duration(seconds: 10);
  static const Duration _movementTick = Duration(milliseconds: 100);
  static const int _pickupProgressNotificationId = 3001;

  final MapStyleLoader _styleLoader = const MapStyleLoader();
  final LocationPermissionGuard _locationGuard =
      const LocationPermissionGuard();
  final DirectionsRouteService _directionsRouteService =
      DirectionsRouteService();

  AppMapController? _mapController;
  String? _mapStyle;
  BitmapDescriptor? _driverMarkerIcon;
  final ValueNotifier<int> _mapFrameTick = ValueNotifier<int>(0);
  List<LatLng> _routePoints = const <LatLng>[];
  List<double> _routeCumulativeMeters = const <double>[];
  double _routeTotalMeters = 0;
  LatLng _driverPoint = _fallbackDriverPoint;
  double _driverProgress = 0;
  int _movementTickCount = 0;
  int _totalMovementTicks = 1;
  Timer? _movementTimer;
  LocationIssue? _locationIssue;
  bool _driverMovingNotified = false;
  bool _pickupReachedNotified = false;
  int _lastPickupProgressNotified = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(NotificationPermissionHelper.ensureRequestedOnce());
    _loadMapStyle();
    _loadDriverMarkerIcon();
    unawaited(_refreshLocationState(requestPermission: true));
    _initializeTracking();
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

  Future<void> _loadDriverMarkerIcon() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(44, 44)),
        AppAssets.mapBike,
      );
      if (!mounted) return;
      setState(() => _driverMarkerIcon = icon);
    } catch (_) {}
  }

  Future<void> _initializeTracking() async {
    final LatLng current = await _loadCurrentDriverLocation();
    final List<LatLng>? roadRoute = await _fetchRoadRoute(
      origin: current,
      destination: widget.pickupPoint,
    );
    if (!mounted) return;

    setState(() {
      _driverPoint = current;
      _driverProgress = 0;
      _movementTickCount = 0;
      _totalMovementTicks =
          (_routeTravelDuration.inMilliseconds / _movementTick.inMilliseconds)
              .round();
      _routePoints = (roadRoute != null && roadRoute.length > 1)
          ? _optimizeRoutePoints(roadRoute)
          : _buildRoutePoints(current, widget.pickupPoint);
      final routeMeta = _buildRouteDistanceMeta(_routePoints);
      _routeCumulativeMeters = routeMeta.cumulativeMeters;
      _routeTotalMeters = routeMeta.totalMeters;
    });

    _notifyDriverMovingIfNeeded();
    _startDriverMovement();
    await _focusRouteInView();
  }

  void _notifyDriverMovingIfNeeded() {
    if (_driverMovingNotified) return;
    _driverMovingNotified = true;
    NotificationsFeed.add(
      title: 'Driver moving to pickup',
      message: 'Driver is on the way to pickup location.',
      pushToDevice: false,
    );
    unawaited(
      LocalNotificationService.showProgress(
        id: _pickupProgressNotificationId,
        title: 'Heading to pickup location',
        body: 'Driver is moving towards pickup.',
        progress: 0,
        maxProgress: 100,
      ),
    );
    unawaited(
      TripBackgroundService.startTrip(
        title: 'Heading to pickup location',
        subtitle: 'Driver is moving to pickup',
        duration: _routeTravelDuration,
      ),
    );
  }

  Future<LatLng> _loadCurrentDriverLocation() async {
    try {
      final result = await _locationGuard.ensureReady(requestPermission: true);
      if (!mounted) return _fallbackDriverPoint;
      setState(() => _locationIssue = result.issue);
      if (!result.isReady) {
        return _fallbackDriverPoint;
      }

      final Position? known = await Geolocator.getLastKnownPosition();
      if (known != null) {
        return LatLng(known.latitude, known.longitude);
      }

      final Position fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(fresh.latitude, fresh.longitude);
    } catch (_) {
      return _fallbackDriverPoint;
    }
  }

  Future<List<LatLng>?> _fetchRoadRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    return _directionsRouteService.fetchDrivingRoute(
      origin: origin,
      destination: destination,
      apiKey: Env.googleMapsApiKey,
    );
  }

  void _startDriverMovement() {
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(_movementTick, (_) async {
      if (!mounted) return;
      if (_driverProgress >= 1 || _movementTickCount >= _totalMovementTicks) {
        _driverProgress = 1;
        _driverPoint = widget.pickupPoint;
        _mapFrameTick.value++;
        _movementTimer?.cancel();
        _notifyPickupReached();
        return;
      }

      _movementTickCount += 1;
      final double next = (_movementTickCount / _totalMovementTicks).clamp(
        0,
        1,
      );
      final LatLng nextPoint = _pointAtProgressByDistance(next);

      _driverProgress = next;
      _driverPoint = nextPoint;
      _mapFrameTick.value++;
      unawaited(_updatePickupProgressNotification(_driverProgress));
    });
  }

  Future<void> _updatePickupProgressNotification(double progress) async {
    final int percent = (progress * 100).round().clamp(0, 100);
    if (percent < 100 && percent % 5 != 0) return;
    if (percent == _lastPickupProgressNotified) return;
    _lastPickupProgressNotified = percent;
    await LocalNotificationService.showProgress(
      id: _pickupProgressNotificationId,
      title: 'Heading to pickup location',
      body: 'Progress: $percent%',
      progress: percent,
      maxProgress: 100,
    );
  }

  void _notifyPickupReached() {
    if (_pickupReachedNotified) return;
    _pickupReachedNotified = true;
    NotificationsFeed.add(
      title: 'Reached pickup location',
      message: 'Driver reached pickup point. Rider has been notified.',
      pushToDevice: false,
    );
    unawaited(
      LocalNotificationService.show(
        id: _pickupProgressNotificationId,
        title: 'Reached pickup location',
        body: 'Driver reached pickup point.',
      ),
    );
    unawaited(TripBackgroundService.stopTrip());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _movementTimer?.cancel();
    _mapFrameTick.dispose();
    unawaited(TripBackgroundService.stopTrip());
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

  Future<void> _showCancellationReasonSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CancellationReasonSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ValueListenableBuilder<int>(
              valueListenable: _mapFrameTick,
              builder: (context, value, child) => AppGoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _driverPoint,
                  zoom: 15,
                ),
                style: _mapStyle,
                markers: _buildMarkers(),
                polylines: <Polyline>{
                  Polyline(
                    polylineId: const PolylineId('driver_to_pickup_done'),
                    points: _passedRoutePoints(),
                    color: AppColors.neutralAAA,
                    width: 4,
                  ),
                  Polyline(
                    polylineId: const PolylineId('driver_to_pickup'),
                    points: _remainingRoutePoints(),
                    color: AppColors.emerald,
                    width: 5,
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  unawaited(_focusRouteInView());
                },
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 235,
            child: GestureDetector(
              onTap: _recenterToDriver,
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
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.neutral666,
                ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
                    const SizedBox(height: 14),
                    const _DriverCard(),
                    const SizedBox(height: 14),
                    const _TripMetrics(),
                    const SizedBox(height: 12),
                    const _PickupDropSection(),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ShadowButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          NotificationsFeed.add(
                            title: 'OTP verification started',
                            message:
                                'Driver arrived. Ask rider for OTP to start trip.',
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const EnterRideCodePage(),
                            ),
                          );
                        },
                        child: const Text(
                          'I Have Arrived',
                          style: TextStyle(
                            fontSize: 24 / 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _showCancellationReasonSheet,
                      child: const Text(
                        'Cancel Ride',
                        style: TextStyle(
                          color: AppColors.validationRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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

