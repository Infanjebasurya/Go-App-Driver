import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/app_assets.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/core/widgets/location_disabled_banner.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_state.dart';
import 'package:goapp/features/ride_complete/presentation/pages/ride_completed_screen.dart';
import 'package:goapp/features/sos/presentation/widgets/sos_bottom_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TripNavigationCubit>().start();
    });
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
          BlocBuilder<TripNavigationCubit, TripNavigationState>(
            buildWhen: (previous, current) =>
                previous.progress != current.progress ||
                previous.showArrivalSheet != current.showArrivalSheet,
            builder: (BuildContext context, TripNavigationState state) {
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

class _TurnIconBadge extends StatelessWidget {
  const _TurnIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.turn_right_rounded, color: AppColors.white),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'SOS',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationButton extends StatelessWidget {
  const _CurrentLocationButton();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ReachedCustomerSheet extends StatelessWidget {
  const _ReachedCustomerSheet({required this.onCompleteTap});

  final VoidCallback onCompleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
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
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reached Customer location',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.emerald,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/image/profile.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sam Yogi',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral333,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 13,
                            color: AppColors.starYellow,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4.9 Rating',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral888,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral888,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2.1 km',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral333,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _PickupDropInfo(),
            const SizedBox(height: 16),
            _SlideToCompleteButton(onCompleted: onCompleteTap),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              color: AppColors.surfaceF0,
              child: const Row(
                children: <Widget>[
                  Text(
                    'Ride in progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral666,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Total Fare: ₹1,250',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral555,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideToCompleteButton extends StatefulWidget {
  const _SlideToCompleteButton({required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<_SlideToCompleteButton> createState() => _SlideToCompleteButtonState();
}

class _SlideToCompleteButtonState extends State<_SlideToCompleteButton> {
  static const double _thumbSize = 44;
  static const double _padding = 2;
  static const double _completeThreshold = 0.92;

  double _dragX = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxDrag =
              constraints.maxWidth - _thumbSize - (_padding * 2);
          final double clampedDrag = _dragX.clamp(0, maxDrag);

          return GestureDetector(
            onHorizontalDragUpdate: _completed
                ? null
                : (DragUpdateDetails details) {
                    setState(() {
                      _dragX = (_dragX + details.delta.dx).clamp(0, maxDrag);
                    });
                  },
            onHorizontalDragEnd: _completed
                ? null
                : (_) {
                    final bool didComplete =
                        maxDrag > 0 &&
                        (clampedDrag / maxDrag) >= _completeThreshold;
                    if (didComplete) {
                      setState(() {
                        _completed = true;
                        _dragX = maxDrag;
                      });
                      widget.onCompleted();
                      return;
                    }
                    setState(() => _dragX = 0);
                  },
            child: Stack(
              children: <Widget>[
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Slide to Complete',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  left: _padding + clampedDrag,
                  top: _padding,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PickupDropInfo extends StatelessWidget {
  const _PickupDropInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 18,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 3),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.surfaceFDF8,
                  border: Border.all(color: AppColors.emerald, width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 1.2, height: 34, color: AppColors.neutralAAA),
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.neutral333,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pickup',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral666,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '42, I-Block, Arumbakkam, Chennai-106',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral333,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Dropoff',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral666,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '13, vinobaji St, KamarajarNagar, NGO....',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral333,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
