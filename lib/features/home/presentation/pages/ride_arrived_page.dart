import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';
import 'package:goapp/core/service/location_service.dart';
import 'package:goapp/core/storage/home_trip_resume_store.dart';
import 'package:goapp/core/storage/profile_display_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/storage/trip_session_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/app_assets.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/core/background/trip_background_service.dart';
import 'package:goapp/features/home/presentation/cubit/driver_status_cubit.dart';
import 'package:goapp/features/home/presentation/pages/enter_ride_code_page.dart';
import 'package:goapp/features/home/presentation/pages/home_page.dart';
import 'package:goapp/features/home/presentation/pages/contact/ride_call_page.dart';
import 'package:goapp/features/home/presentation/pages/contact/ride_chat_page.dart';
import 'package:goapp/features/home/presentation/widgets/home_no_device_back.dart';
import 'package:goapp/features/notifications/presentation/model/notifications_feed.dart';
import 'package:goapp/core/di/injection.dart';

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
  late final LocationPermissionGuard _locationGuard;
  late final LocationService _locationService;
  late final DirectionsRouteService _directionsRouteService;

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
  bool _isLocationDialogVisible = false;
  bool _driverMovingNotified = false;
  bool _pickupReachedNotified = false;
  int _lastPickupProgressNotified = -1;
  String _fareLabel = '\u20B990';
  String _distanceLabel = '2.1 km';
  String _pickupAddress = '42, I-Block, Arumbakkam, Chennai-106';
  String _dropAddress = '13, vinobaji St, Kamarajar Nagar, NGO...';

  @override
  void initState() {
    super.initState();
    _locationGuard = sl<LocationPermissionGuard>();
    _locationService = sl<LocationService>();
    _directionsRouteService = sl<DirectionsRouteService>();
    unawaited(HomeTripResumeStore.setStage(HomeTripResumeStage.rideArrived));
    if (Env.mockApi) {
      unawaited(HomeTripResumeStore.markForceHomeOnNextLaunch());
    }
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyle();
    _loadDriverMarkerIcon();
    unawaited(_refreshLocationState(requestPermission: true));
    unawaited(_loadTripSessionUiData());
    _initializeTracking();
  }

  Future<void> _loadTripSessionUiData() async {
    final TripSession? session = await TripSessionStore.loadActive();
    if (!mounted || session == null) return;
    setState(() {
      if (session.fareLabel.isNotEmpty) {
        _fareLabel = session.fareLabel;
      }
      if (session.distanceLabel.isNotEmpty) {
        _distanceLabel = session.distanceLabel;
      }
      if (session.pickupAddress.isNotEmpty) {
        _pickupAddress = session.pickupAddress;
      }
      if (session.dropAddress.isNotEmpty) {
        _dropAddress = session.dropAddress;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshLocationState());
    }
  }

  Future<void> _refreshLocationState({bool requestPermission = false}) async {
    final previousIssue = _locationIssue;
    final result = await _locationGuard.ensureReady(
      requestPermission: requestPermission,
    );
    if (!mounted) return;
    setState(() => _locationIssue = result.issue);
    if (previousIssue != result.issue && result.issue != null) {
      unawaited(_showLocationBlockedDialog(result.issue!));
    }
    _handleTrackingLocationState(previousIssue, result.issue);
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

      final AppLocationPosition? known = await _locationService.getLastKnownPosition();
      if (known != null) {
        return LatLng(known.latitude, known.longitude);
      }

      final AppLocationPosition fresh = await _locationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
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
      apiKey: _resolveDirectionsApiKey(),
    );
  }

  String _resolveDirectionsApiKey() {
    if (Env.googleMapsApiKey.isNotEmpty) return Env.googleMapsApiKey;
    if (Env.googlePlacesApiKey.isNotEmpty) return Env.googlePlacesApiKey;
    if (Env.googleGeocodingApiKey.isNotEmpty) return Env.googleGeocodingApiKey;
    return '';
  }

  void _startDriverMovement() {
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(_movementTick, (_) async {
      if (!mounted) return;
      if (_locationIssue != null) return;
      if (_driverProgress >= 1 || _movementTickCount >= _totalMovementTicks) {
        _driverProgress = 1;
        _driverPoint = widget.pickupPoint;
        _mapFrameTick.value++;
        unawaited(_mapController?.animateTo(_driverPoint, zoom: 15.5));
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
      unawaited(_mapController?.animateTo(_driverPoint, zoom: 15.5));
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

  void _handleTrackingLocationState(
    LocationIssue? previousIssue,
    LocationIssue? nextIssue,
  ) {
    if (nextIssue != null) {
      unawaited(TripBackgroundService.stopTrip());
      return;
    }

    if (previousIssue == null) return;
    final int remainingSeconds = ((1 - _driverProgress) * 10)
        .clamp(1, 10)
        .round();
    unawaited(
      TripBackgroundService.startTrip(
        title: 'Heading to pickup location',
        subtitle: 'Driver is moving to pickup',
        duration: Duration(seconds: remainingSeconds),
      ),
    );
    if (_driverProgress <= 0.02) {
      unawaited(_initializeTracking());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _movementTimer?.cancel();
    _mapFrameTick.dispose();
    unawaited(TripBackgroundService.stopTrip());
    super.dispose();
  }

  Future<void> _onLocationDialogActionTap() async {
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

  Future<void> _showLocationBlockedDialog(LocationIssue issue) async {
    if (!mounted || _isLocationDialogVisible) return;
    _isLocationDialogVisible = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Location Required'),
          content: Text(_locationBlockedMessage(issue)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _onLocationDialogActionTap();
              },
              child: Text(
                issue == LocationIssue.serviceDisabled
                    ? 'Enable GPS'
                    : 'Open Settings',
              ),
            ),
          ],
        );
      },
    );
    _isLocationDialogVisible = false;
  }

  Future<void> _showCancellationReasonSheet() {
    final double customerCancellationFee = _cancellationFeeFor('customer');
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => _CancellationReasonSheet(
        customerCancellationFee: customerCancellationFee,
        onConfirm: (String canceledBy, String reason) async {
          final double cancellationFee = _cancellationFeeFor(canceledBy);
          await RideHistoryStore.markCanceledNowOrCreate(
            canceledBy: canceledBy,
            cancelReason: reason,
            pickupLocation: _pickupAddress,
            dropLocation: _dropAddress,
            fareLabel: cancellationFee > 0
                ? '\u20B9 ${cancellationFee.toStringAsFixed(2)}'
                : null,
            cancellationFeeAmount: cancellationFee,
          );
          await HomeTripResumeStore.clear();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => BlocProvider<DriverCubit>(
                create: (_) => sl<DriverCubit>(),
                child: const HomeScreen(),
              ),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  double _cancellationFeeFor(String canceledBy) {
    final String normalized = canceledBy.trim().toLowerCase();
    if (normalized == 'customer') {
      final double km = _parseDistanceKm(_distanceLabel);
      if (km <= 0) return 20.0;
      return km <= 3.0 ? 20.0 : 30.0;
    }
    return 0;
  }

  double _parseDistanceKm(String raw) {
    final String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }

  String _estimateArrivalLabel() {
    final double metersLeft = _metersToPickup();
    final double kmLeft = metersLeft / 1000;
    final int minutes = ((kmLeft / 24) * 60).ceil().clamp(1, 99);
    return '$minutes mins';
  }

  void _openChatScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RideChatPage()));
  }

  void _openCallScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RideCallPage()));
  }

  @override
  Widget build(BuildContext context) {
    return HomeNoDeviceBack(
      child: Scaffold(
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
                      _DriverCard(
                        onChatTap: _openChatScreen,
                        onCallTap: _openCallScreen,
                      ),
                      const SizedBox(height: 14),
                      ValueListenableBuilder<int>(
                        valueListenable: _mapFrameTick,
                        builder: (context, value, child) {
                          return _TripMetrics(
                            fareLabel: _fareLabel,
                            distanceLabel: _distanceLabel,
                            arrivalLabel: _estimateArrivalLabel(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _PickupDropSection(
                        pickupAddress: _pickupAddress,
                        dropAddress: _dropAddress,
                      ),
                      const SizedBox(height: 18),
                      ValueListenableBuilder<int>(
                        valueListenable: _mapFrameTick,
                        builder: (context, value, child) {
                          final bool canProceed = _canProceedToRideCode();
                          final int metersLeft = _metersToPickup()
                              .round()
                              .clamp(0, 99999);
                          final bool hasLocationIssue = _locationIssue != null;
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor:
                                        AppColors.neutralCCC,
                                    disabledForegroundColor:
                                        AppColors.neutral666,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: canProceed
                                      ? () async {
                                          await RideHistoryStore.markPickedUpNow();
                                          // TripSessionStore: captain arrived at pickup.
                                          unawaited(
                                            TripSessionStore.markArrivedAtPickup(),
                                          );
                                          if (!context.mounted) return;
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  const EnterRideCodePage(),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: const Text(
                                    'I Have Arrived',
                                    style: TextStyle(
                                      fontSize: 24 / 2,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                hasLocationIssue
                                    ? _locationBlockedMessage(_locationIssue!)
                                    : canProceed
                                    ? 'You are within 100m of pickup.'
                                    : 'Move closer to pickup ($metersLeft m left).',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: hasLocationIssue
                                      ? AppColors.validationRed
                                      : canProceed
                                      ? AppColors.emerald
                                      : AppColors.neutral666,
                                ),
                              ),
                            ],
                          );
                        },
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
      ),
    );
  }

  String _locationBlockedMessage(LocationIssue issue) {
    switch (issue) {
      case LocationIssue.serviceDisabled:
        return 'Enable GPS to continue route simulation.';
      case LocationIssue.permissionDenied:
        return 'Allow location permission to continue route simulation.';
      case LocationIssue.permissionDeniedForever:
        return 'Enable location permission from settings to continue.';
    }
  }
}



