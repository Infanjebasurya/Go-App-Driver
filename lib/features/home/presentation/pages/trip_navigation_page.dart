import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/background/trip_background_service.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';
import 'package:goapp/core/notifications/local_notification_service.dart';
import 'package:goapp/core/permissions/notification_permission_helper.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/app_assets.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/core/widgets/location_disabled_banner.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_state.dart';
import 'package:goapp/features/notifications/presentation/model/notifications_feed.dart';
import 'package:goapp/features/ride_complete/presentation/pages/ride_completed_screen.dart';
import 'package:goapp/features/sos/presentation/widgets/sos_bottom_sheet.dart';

part 'trip_navigation_page_sections.dart';

class TripNavigationPage extends StatelessWidget {
  const TripNavigationPage({super.key, this.initialRoutePath});

  final List<LatLng>? initialRoutePath;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TripNavigationCubit>(
      create: (_) => TripNavigationCubit(),
      child: _TripNavigationView(initialRoutePath: initialRoutePath),
    );
  }
}

class _TripNavigationView extends StatefulWidget {
  const _TripNavigationView({this.initialRoutePath});

  final List<LatLng>? initialRoutePath;

  @override
  State<_TripNavigationView> createState() => _TripNavigationViewState();
}

class _TripNavigationViewState extends State<_TripNavigationView>
    with WidgetsBindingObserver {
  static const LatLng _driverPoint = LatLng(13.0565, 80.2138);
  static const LatLng _destinationPoint = LatLng(13.0699, 80.2218);
  static const int _dropProgressNotificationId = 3002;

  final MapStyleLoader _styleLoader = const MapStyleLoader();
  final LocationPermissionGuard _locationGuard =
      const LocationPermissionGuard();
  final DirectionsRouteService _directionsRouteService =
      DirectionsRouteService();
  late List<LatLng> _mapRoutePath = _buildCurvedRoutePath(
    _driverPoint,
    _destinationPoint,
  );
  bool _tripStarted = false;
  String? _mapStyle;
  BitmapDescriptor? _bikeMarkerIcon;
  LocationIssue? _locationIssue;
  bool _arrivalNotified = false;
  int _lastDropProgressNotified = -1;
  bool _dropProgressStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(NotificationPermissionHelper.ensureRequestedOnce());
    _loadMapStyle();
    _loadBikeIcon();
    unawaited(_refreshLocationState(requestPermission: true));
    if (widget.initialRoutePath != null &&
        widget.initialRoutePath!.length > 1) {
      _mapRoutePath = _optimizeRoutePoints(widget.initialRoutePath!);
      _startTripIfReady();
    } else {
      _loadRoadRoutePath();
    }
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
      destination: _destinationPoint,
    );
    if (!mounted) return;
    if (roadRoute == null || roadRoute.length < 2) {
      _mapRoutePath = _buildCurvedRoutePath(_driverPoint, _destinationPoint);
    } else {
      _mapRoutePath = _optimizeRoutePoints(roadRoute);
    }
    setState(() {});
    _startTripIfReady();
  }

  void _startTripIfReady() {
    if (_tripStarted || _mapRoutePath.length < 2) return;
    _tripStarted = true;
    unawaited(
      TripBackgroundService.startTrip(
        title: 'Trip in progress',
        subtitle: 'Heading to drop location',
        duration: const Duration(seconds: 10),
      ),
    );
    _startDropProgressNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TripNavigationCubit>().start();
    });
  }

  void _startDropProgressNotification() {
    if (_dropProgressStarted) return;
    _dropProgressStarted = true;
    unawaited(
      LocalNotificationService.showProgress(
        id: _dropProgressNotificationId,
        title: 'Trip in progress',
        body: 'Heading to drop location.',
        progress: 0,
        maxProgress: 100,
      ),
    );
  }

  Future<List<LatLng>?> _fetchRoadRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    return _directionsRouteService.fetchDrivingRoute(
      origin: origin,
      destination: destination,
      apiKey: Env.googleMapsApiKey,
      preferDetailedSteps: true,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          BlocBuilder<TripNavigationCubit, TripNavigationState>(
            buildWhen: (previous, current) =>
                previous.progress != current.progress ||
                previous.showArrivalSheet != current.showArrivalSheet,
            builder: (BuildContext context, TripNavigationState state) {
              _notifyDropProgress(state.progress);
              _notifyArrivalIfNeeded(state.showArrivalSheet);
              final cubit = context.read<TripNavigationCubit>();
              final List<LatLng> routePoints = cubit.currentRoutePoints(
                _mapRoutePath,
              );
              final LatLng bikePoint = cubit.pointAlongRoute(_mapRoutePath);

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
                          position: _destinationPoint,
                          infoWindow: const InfoWindow(title: 'Drop'),
                        ),
                        Marker(
                          markerId: const MarkerId('bike_marker'),
                          position: bikePoint,
                          icon: _bikeMarkerIcon,
                          infoWindow: const InfoWindow(title: 'Driver'),
                        ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          text: '${state.remainingMeters}m ',
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
                                            color: AppColors.white.withValues(
                                              alpha: 0.85,
                                            ),
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
                          onCompleteTap: () {
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
    );
  }
}
