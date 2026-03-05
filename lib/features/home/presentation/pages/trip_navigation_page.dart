import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/background/trip_background_service.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';
import 'package:goapp/core/storage/home_trip_resume_store.dart';
import 'package:goapp/core/storage/profile_display_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/storage/trip_session_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/app_assets.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/core/widgets/location_disabled_banner.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_state.dart';
import 'package:goapp/features/home/presentation/widgets/home_no_device_back.dart';
import 'package:goapp/features/notifications/presentation/model/notifications_feed.dart';
import 'package:goapp/features/ride_complete/presentation/pages/ride_completed_screen.dart';
import 'package:goapp/features/sos/presentation/widgets/sos_bottom_sheet.dart';

part 'trip_navigation_page_sections.dart';

class TripNavigationPage extends StatelessWidget {
  // B-05 FIX: dropPoint is now required so the real destination is used.
  const TripNavigationPage({
    super.key,
    this.initialRoutePath,
    required this.dropPoint,
  });

  final List<LatLng>? initialRoutePath;
  final LatLng dropPoint;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TripNavigationCubit>(
      create: (_) => TripNavigationCubit(),
      child: _TripNavigationView(
        initialRoutePath: initialRoutePath,
        dropPoint: dropPoint,
      ),
    );
  }
}

class _TripNavigationView extends StatefulWidget {
  // B-05 FIX: dropPoint propagated from TripNavigationPage.
  const _TripNavigationView({this.initialRoutePath, required this.dropPoint});

  final List<LatLng>? initialRoutePath;
  final LatLng dropPoint;

  @override
  State<_TripNavigationView> createState() => _TripNavigationViewState();
}

class _TripNavigationViewState extends State<_TripNavigationView>
    with WidgetsBindingObserver {
  static const LatLng _driverPoint = LatLng(13.0565, 80.2138);
  // B-05 FIX: widget.dropPoint removed; use widget.dropPoint everywhere.
  static const int _dropProgressNotificationId = 3002;

  final MapStyleLoader _styleLoader = const MapStyleLoader();
  final LocationPermissionGuard _locationGuard =
      const LocationPermissionGuard();
  final DirectionsRouteService _directionsRouteService =
      DirectionsRouteService();
  late List<LatLng> _mapRoutePath = _buildCurvedRoutePath(
    _driverPoint,
    widget.dropPoint,
  );
  bool _tripStarted = false;
  bool _routePrepared = false;
  String? _mapStyle;
  BitmapDescriptor? _bikeMarkerIcon;
  LocationIssue? _locationIssue;
  bool _arrivalNotified = false;
  int _lastDropProgressNotified = -1;
  bool _dropProgressStarted = false;
  Timer? _dropProgressTimer;
  int? _tripStartEpochMs;
  String _fareLabel = '\u20B990';
  String _distanceLabel = '2.1 km';
  String _pickupAddress = '42, I-Block, Arumbakkam, Chennai-106';
  String _dropAddress = '13, vinobaji St, KamarajarNagar, NGO....';
  AppMapController? _mapController;

  @override
  void initState() {
    super.initState();
    unawaited(HomeTripResumeStore.setStage(HomeTripResumeStage.tripNavigation));
    if (Env.mockApi) {
      unawaited(HomeTripResumeStore.markForceHomeOnNextLaunch());
    }
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyle();
    _loadBikeIcon();
    unawaited(_loadTripSessionUiData());
    unawaited(_refreshLocationState(requestPermission: true));
    if (widget.initialRoutePath != null &&
        widget.initialRoutePath!.length > 1) {
      _mapRoutePath = _optimizeRoutePoints(widget.initialRoutePath!);
      _routePrepared = true;
      unawaited(_startTripIfReady());
    } else {
      _loadRoadRoutePath();
    }
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
      context.read<TripNavigationCubit>().syncWithNow();
      _updateDropProgressNotificationFromClock();
    }
  }

  Future<void> _refreshLocationState({bool requestPermission = false}) async {
    final previousIssue = _locationIssue;
    final result = await _locationGuard.ensureReady(
      requestPermission: requestPermission,
    );
    if (!mounted) return;
    setState(() => _locationIssue = result.issue);
    _applyLocationState(previousIssue: previousIssue, nextIssue: result.issue);
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await _styleLoader.loadBooking();
      if (!mounted) return;
      setState(() => _mapStyle = style);
    } catch (_) {}
  }

  Future<void> _loadBikeIcon() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(44, 44)),
        AppAssets.mapBike,
      );
      if (!mounted) return;
      setState(() => _bikeMarkerIcon = icon);
    } catch (_) {}
  }

  Future<void> _loadRoadRoutePath() async {
    final List<LatLng>? roadRoute = await _fetchRoadRoute(
      origin: _driverPoint,
      destination: widget.dropPoint,
    );
    if (!mounted) return;
    if (roadRoute == null || roadRoute.length < 2) {
      _mapRoutePath = _buildCurvedRoutePath(_driverPoint, widget.dropPoint);
    } else {
      _mapRoutePath = _optimizeRoutePoints(roadRoute);
    }
    _routePrepared = true;
    setState(() {});
    unawaited(_startTripIfReady());
  }

  Future<void> _startTripIfReady() async {
    if (_tripStarted ||
        !_routePrepared ||
        _mapRoutePath.length < 2 ||
        _locationIssue != null) {
      return;
    }
    _tripStarted = true;
    final int startEpochMs =
        await HomeTripResumeStore.loadTripNavigationStartEpochMs() ??
        DateTime.now().millisecondsSinceEpoch;
    _tripStartEpochMs = startEpochMs;
    await HomeTripResumeStore.setTripNavigationStartEpochMs(startEpochMs);
    if (!mounted) return;
    unawaited(
      TripBackgroundService.startTrip(
        title: 'Trip in progress',
        subtitle: 'Heading to drop location',
        duration: const Duration(seconds: 10),
      ),
    );
    _startDropProgressNotification();
    _startDropProgressNotificationTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TripNavigationCubit>().start(startedAtEpochMs: startEpochMs);
    });
  }

  void _startDropProgressNotification() {
    if (_dropProgressStarted) return;
    _dropProgressStarted = true;
    final int initialPercent = _progressPercentFromClock();
    _lastDropProgressNotified = initialPercent;
    unawaited(
      LocalNotificationService.showProgress(
        id: _dropProgressNotificationId,
        title: 'Trip in progress',
        body: 'Heading to drop location.',
        progress: initialPercent,
        maxProgress: 100,
      ),
    );
  }

  void _startDropProgressNotificationTimer() {
    _dropProgressTimer?.cancel();
    _dropProgressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDropProgressNotificationFromClock();
    });
  }

  void _applyLocationState({
    required LocationIssue? previousIssue,
    required LocationIssue? nextIssue,
  }) {
    final cubit = context.read<TripNavigationCubit>();
    if (nextIssue != null) {
      // B-12 FIX: Pause the trip timer when GPS/permission drops.
      // Previously both branches called setPaused(false) so the trip could
      // never be paused.
      cubit.setPaused(true);
      return;
    }

    // GPS restored — resume.
    cubit.setPaused(false);

    if (!_tripStarted) {
      unawaited(_startTripIfReady());
      return;
    }
    if (_arrivalNotified) return;

    _startDropProgressNotificationTimer();
    final int remainingSeconds = ((1 - cubit.state.progress) * 10)
        .clamp(1, 10)
        .round();
    unawaited(
      TripBackgroundService.startTrip(
        title: 'Trip in progress',
        subtitle: 'Heading to drop location',
        duration: Duration(seconds: remainingSeconds),
      ),
    );
  }

  int _progressPercentFromClock() {
    final int? started = _tripStartEpochMs;
    if (started == null) return 0;
    final int elapsedMs = DateTime.now().millisecondsSinceEpoch - started;
    final double progress = (elapsedMs / 10000).clamp(0, 1);
    return (progress * 100).round().clamp(0, 100);
  }

  void _updateDropProgressNotificationFromClock() {
    if (_arrivalNotified) return;
    final int percent = _progressPercentFromClock();
    if (percent == _lastDropProgressNotified) return;
    _lastDropProgressNotified = percent;
    unawaited(
      LocalNotificationService.showProgress(
        id: _dropProgressNotificationId,
        title: 'Trip in progress',
        body: 'Progress: $percent%',
        progress: percent,
        maxProgress: 100,
      ),
    );
  }

  Future<List<LatLng>?> _fetchRoadRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String apiKey = _resolveDirectionsApiKey();
    if (apiKey.isEmpty) return null;
    return _directionsRouteService.fetchDrivingRoute(
      origin: origin,
      destination: destination,
      apiKey: apiKey,
      preferDetailedSteps: true,
    );
  }

  String _resolveDirectionsApiKey() {
    if (Env.googleMapsApiKey.isNotEmpty) return Env.googleMapsApiKey;
    if (Env.googlePlacesApiKey.isNotEmpty) return Env.googlePlacesApiKey;
    if (Env.googleGeocodingApiKey.isNotEmpty) return Env.googleGeocodingApiKey;
    return '';
  }

  List<LatLng> _buildCurvedRoutePath(LatLng from, LatLng to) {
    const int samples = 100;
    final double dLat = to.latitude - from.latitude;
    final double dLng = to.longitude - from.longitude;
    final double controlLift = 0.0013;

    final LatLng controlA = LatLng(
      from.latitude + dLat * 0.28 + controlLift,
      from.longitude + dLng * 0.28 + 0.00015,
    );
    final LatLng controlB = LatLng(
      from.latitude + dLat * 0.74 - (controlLift * 0.65),
      from.longitude + dLng * 0.74 + 0.00026,
    );

    final List<LatLng> points = <LatLng>[];
    for (int i = 0; i <= samples; i++) {
      final double t = i / samples;
      final double oneMinusT = 1 - t;
      points.add(
        LatLng(
          (oneMinusT * oneMinusT * oneMinusT) * from.latitude +
              (3 * oneMinusT * oneMinusT * t) * controlA.latitude +
              (3 * oneMinusT * t * t) * controlB.latitude +
              (t * t * t) * to.latitude,
          (oneMinusT * oneMinusT * oneMinusT) * from.longitude +
              (3 * oneMinusT * oneMinusT * t) * controlA.longitude +
              (3 * oneMinusT * t * t) * controlB.longitude +
              (t * t * t) * to.longitude,
        ),
      );
    }
    return _optimizeRoutePoints(points);
  }

  List<LatLng> _optimizeRoutePoints(List<LatLng> points) {
    if (points.length <= 180) return points;
    final List<LatLng> optimized = <LatLng>[points.first];
    final int step = (points.length / 180).ceil();
    for (int i = step; i < points.length - 1; i += step) {
      optimized.add(points[i]);
    }
    optimized.add(points.last);
    return optimized;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dropProgressTimer?.cancel();
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

  void _notifyArrivalIfNeeded(bool showArrivalSheet) {
    if (!showArrivalSheet || _arrivalNotified) return;
    _arrivalNotified = true;
    _dropProgressTimer?.cancel();
    unawaited(HomeTripResumeStore.clearTripNavigationStartEpochMs());
    NotificationsFeed.add(
      title: 'Reached drop location',
      message: 'Rider notified that driver reached destination.',
      pushToDevice: false,
    );
    unawaited(
      LocalNotificationService.show(
        id: _dropProgressNotificationId,
        title: 'Reached drop location',
        body: 'Driver reached destination.',
      ),
    );
    unawaited(TripBackgroundService.stopTrip());
  }

  void _notifyDropProgress(double progress) {
    if (_arrivalNotified) return;
    final int percent = (progress * 100).round().clamp(0, 100);
    if (percent < 100 && percent % 5 != 0) return;
    if (percent == _lastDropProgressNotified) return;
    _lastDropProgressNotified = percent;
    unawaited(
      LocalNotificationService.showProgress(
        id: _dropProgressNotificationId,
        title: 'Trip in progress',
        body: 'Progress: $percent%',
        progress: percent,
        maxProgress: 100,
      ),
    );
  }

  double _distanceMeters(LatLng from, LatLng to) {
    const double earthRadius = 6371000;
    final double dLat = (to.latitude - from.latitude) * math.pi / 180;
    final double dLng = (to.longitude - from.longitude) * math.pi / 180;
    final double lat1 = from.latitude * math.pi / 180;
    final double lat2 = to.latitude * math.pi / 180;
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return HomeNoDeviceBack(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            // B-01 + B-02 FIX: All side effects live here in BlocListener,
            // never inside the BlocBuilder's builder().
            BlocListener<TripNavigationCubit, TripNavigationState>(
              listener: (context, state) {
                _notifyDropProgress(state.progress);
                _notifyArrivalIfNeeded(state.showArrivalSheet);
                // Arrival detection: measure distance and call markArrived()
                // safely outside the build phase.
                if (!state.showArrivalSheet && !state.isPaused) {
                  final cubit = context.read<TripNavigationCubit>();
                  final LatLng bikePoint = cubit.pointAlongRoute(_mapRoutePath);
                  unawaited(_mapController?.animateTo(bikePoint, zoom: 15.5));
                  final double metersToDrop = _distanceMeters(
                    bikePoint,
                    widget.dropPoint,
                  );
                  if (metersToDrop <= 100) {
                    cubit.markArrived();
                  }
                }
              },
              child: BlocBuilder<TripNavigationCubit, TripNavigationState>(
                buildWhen: (previous, current) =>
                    previous.progress != current.progress ||
                    previous.showArrivalSheet != current.showArrivalSheet ||
                    previous.isPaused != current.isPaused,
                builder: (BuildContext context, TripNavigationState state) {
                  // B-01 + B-02 FIX: No side effects here. Notifications,
                  // timer cancellations and cubit mutations have been moved
                  // to the BlocListener above.
                  final cubit = context.read<TripNavigationCubit>();
                  final List<LatLng> routePoints = cubit.currentRoutePoints(
                    _mapRoutePath,
                  );
                  final LatLng bikePoint = cubit.pointAlongRoute(_mapRoutePath);
                  final int metersToDrop = _distanceMeters(
                    bikePoint,
                    widget.dropPoint,
                  ).round().clamp(0, 99999);

                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: AppGoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(13.0638, 80.2181),
                            zoom: 14.6,
                          ),
                          style: _mapStyle,
                          polylines: <Polyline>{
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: routePoints,
                              color: AppColors.emerald,
                              width: 5,
                            ),
                          },
                          markers: <Marker>{
                            Marker(
                              markerId: const MarkerId('destination_marker'),
                              position: widget.dropPoint,
                              infoWindow: const InfoWindow(title: 'Drop'),
                            ),
                            Marker(
                              markerId: const MarkerId('bike_marker'),
                              position: bikePoint,
                              icon: _bikeMarkerIcon,
                              infoWindow: const InfoWindow(title: 'Driver'),
                            ),
                          },
                          onMapCreated: (controller) {
                            _mapController = controller;
                            unawaited(controller.animateTo(_driverPoint, zoom: 15.5));
                          },
                        ),
                      ),
                      if (!state.showArrivalSheet)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 18,
                          left: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                begin: Alignment(-1, 0.05),
                                end: Alignment(1, 0),
                                colors: <Color>[
                                  AppColors.homeStatusDark,
                                  AppColors.emerald,
                                ],
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                const _TurnIconBadge(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Next Turn',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white.withValues(
                                            alpha: 0.75,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text.rich(
                                        TextSpan(
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text: '${metersToDrop}m ',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'onto Dr.NSK Street Rd',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.white
                                                    .withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                },
              ),
            ), // closes BlocListener (B-01/B-02 fix)
            BlocSelector<TripNavigationCubit, TripNavigationState, bool>(
              selector: (state) => state.showArrivalSheet,
              builder: (context, showArrivalSheet) {
                return Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      right: 14,
                      bottom: showArrivalSheet ? 470 : 122,
                      child: _SosButton(
                        onTap: () => SOSBottomSheet.show(context),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      right: 16,
                      bottom: showArrivalSheet ? 392 : 58,
                      child: const _CurrentLocationButton(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        offset: showArrivalSheet
                            ? Offset.zero
                            : const Offset(0, 1.05),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 280),
                          opacity: showArrivalSheet ? 1 : 0,
                          child: _ReachedCustomerSheet(
                            fareLabel: _fareLabel,
                            distanceLabel: _distanceLabel,
                            pickupAddress: _pickupAddress,
                            dropAddress: _dropAddress,
                            onCompleteTap: () async {
                              // TripSessionStore: drop reached, trip completed.
                              unawaited(TripSessionStore.markTripCompleted());
                              final TripSession? session =
                                  await TripSessionStore.loadActive();
                              final String pickupLocation =
                                  session?.pickupAddress ??
                                  '42, I-Block, Arumbakkam, Chennai-106';
                              final String dropLocation =
                                  session?.dropAddress ??
                                  '13, vinobaji St, Kamarajar Nagar, NGO Colony, Chennai';
                              final String fareLabel =
                                  session?.fareLabel ?? '\u20B990';
                              final String distanceLabel =
                                  session?.distanceLabel ?? '2.1 km';
                              await RideHistoryStore.markCompletedNowOrCreate(
                                pickupLocation: pickupLocation,
                                dropLocation: dropLocation,
                                fareLabel: fareLabel,
                                distanceLabel: distanceLabel,
                              );
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RideCompletedScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
