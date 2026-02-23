import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goapp/core/maps/app_google_map.dart';
import 'package:goapp/core/maps/map_style_loader.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/app_assets.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:goapp/features/home/presentation/pages/enter_ride_code_page.dart';

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

class _RideArrivedPageState extends State<RideArrivedPage> {
  static const LatLng _fallbackDriverPoint = LatLng(13.0624, 80.2098);
  static const Duration _routeTravelDuration = Duration(seconds: 10);
  static const Duration _movementTick = Duration(milliseconds: 100);

  final MapStyleLoader _styleLoader = const MapStyleLoader();
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

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadDriverMarkerIcon();
    _initializeTracking();
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

    _startDriverMovement();
    await _focusRouteInView();
  }

  Future<LatLng> _loadCurrentDriverLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _fallbackDriverPoint;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
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
    });
  }

  LatLng _interpolate(LatLng from, LatLng to, double t) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  List<LatLng> _buildRoutePoints(LatLng from, LatLng to) {
    const int samples = 100;
    final double dLat = to.latitude - from.latitude;
    final double dLng = to.longitude - from.longitude;
    final double distance = math.sqrt((dLat * dLat) + (dLng * dLng));

    if (distance <= 0.00001) {
      return <LatLng>[from, to];
    }

    final double nx = -dLng / distance;
    final double ny = dLat / distance;
    final double curveOffsetA = (distance * 0.16).clamp(0.00015, 0.0010);
    final double curveOffsetB = (distance * 0.10).clamp(0.00012, 0.0009);

    final LatLng controlA = LatLng(
      from.latitude + dLat * 0.28 + (ny * curveOffsetA),
      from.longitude + dLng * 0.28 + (nx * curveOffsetA),
    );
    final LatLng controlB = LatLng(
      from.latitude + dLat * 0.74 - (ny * curveOffsetB),
      from.longitude + dLng * 0.74 - (nx * curveOffsetB),
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

  _RouteDistanceMeta _buildRouteDistanceMeta(List<LatLng> points) {
    if (points.isEmpty) {
      return const _RouteDistanceMeta(
        cumulativeMeters: <double>[0],
        totalMeters: 0,
      );
    }
    final List<double> cumulative = List<double>.filled(points.length, 0);
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += _distanceMeters(points[i - 1], points[i]);
      cumulative[i] = total;
    }
    return _RouteDistanceMeta(cumulativeMeters: cumulative, totalMeters: total);
  }

  LatLng _pointAtProgressByDistance(double progress) {
    if (_routePoints.isEmpty) return _driverPoint;
    if (_routePoints.length == 1 || _routeTotalMeters <= 0) {
      return _routePoints.last;
    }

    final double targetDistance = _routeTotalMeters * progress.clamp(0, 1);
    int segmentIndex = 1;
    while (segmentIndex < _routeCumulativeMeters.length &&
        _routeCumulativeMeters[segmentIndex] < targetDistance) {
      segmentIndex++;
    }

    if (segmentIndex >= _routePoints.length) {
      return _routePoints.last;
    }

    final double segmentEnd = _routeCumulativeMeters[segmentIndex];
    final double segmentStart = _routeCumulativeMeters[segmentIndex - 1];
    final double segmentLength = segmentEnd - segmentStart;
    if (segmentLength <= 0) {
      return _routePoints[segmentIndex];
    }

    final double localT = (targetDistance - segmentStart) / segmentLength;
    return _interpolate(
      _routePoints[segmentIndex - 1],
      _routePoints[segmentIndex],
      localT.clamp(0, 1),
    );
  }

  int _currentSegmentIndex() {
    if (_routePoints.isEmpty ||
        _routeCumulativeMeters.isEmpty ||
        _routeTotalMeters <= 0) {
      return 0;
    }
    final double targetDistance =
        _routeTotalMeters * _driverProgress.clamp(0, 1);
    int segmentIndex = 1;
    while (segmentIndex < _routeCumulativeMeters.length &&
        _routeCumulativeMeters[segmentIndex] < targetDistance) {
      segmentIndex++;
    }
    return segmentIndex.clamp(1, _routePoints.length - 1);
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

  List<LatLng> _passedRoutePoints() {
    if (_routePoints.isEmpty) return <LatLng>[];
    final int segmentIndex = _currentSegmentIndex();
    final LatLng currentPoint = _pointAtProgressByDistance(_driverProgress);

    final List<LatLng> passed = _routePoints
        .take(segmentIndex)
        .toList(growable: true);
    passed.add(currentPoint);
    return passed;
  }

  List<LatLng> _remainingRoutePoints() {
    if (_routePoints.isEmpty) return <LatLng>[];
    final int segmentIndex = _currentSegmentIndex();
    final LatLng currentPoint = _pointAtProgressByDistance(_driverProgress);

    final List<LatLng> remaining = <LatLng>[currentPoint];
    if (segmentIndex < _routePoints.length) {
      remaining.addAll(_routePoints.skip(segmentIndex));
    }
    return remaining;
  }

  Set<Marker> _buildMarkers() {
    return <Marker>{
      Marker(
        markerId: const MarkerId('driver_marker'),
        position: _driverPoint,
        icon: _driverMarkerIcon,
        infoWindow: const InfoWindow(title: 'Driver'),
      ),
      Marker(
        markerId: const MarkerId('pickup_marker'),
        position: widget.pickupPoint,
        infoWindow: const InfoWindow(title: 'Pickup'),
      ),
    };
  }

  Future<void> _recenterToDriver() async {
    await _mapController?.animateTo(_driverPoint, zoom: 15.5);
  }

  Future<void> _focusRouteInView() async {
    final controller = _mapController;
    if (controller == null) return;
    final double minLat = math.min(
      _driverPoint.latitude,
      widget.pickupPoint.latitude,
    );
    final double maxLat = math.max(
      _driverPoint.latitude,
      widget.pickupPoint.latitude,
    );
    final double minLng = math.min(
      _driverPoint.longitude,
      widget.pickupPoint.longitude,
    );
    final double maxLng = math.max(
      _driverPoint.longitude,
      widget.pickupPoint.longitude,
    );

    const double pad = 0.0012;
    await controller.animateToBounds(
      LatLngBounds(
        southwest: LatLng(minLat - pad, minLng - pad),
        northeast: LatLng(maxLat + pad, maxLng + pad),
      ),
      padding: 72,
    );
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _mapFrameTick.dispose();
    super.dispose();
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
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
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

class _RouteDistanceMeta {
  const _RouteDistanceMeta({
    required this.cumulativeMeters,
    required this.totalMeters,
  });

  final List<double> cumulativeMeters;
  final double totalMeters;
}

class _CancellationReasonSheet extends StatefulWidget {
  const _CancellationReasonSheet();

  @override
  State<_CancellationReasonSheet> createState() =>
      _CancellationReasonSheetState();
}

class _CancellationReasonSheetState extends State<_CancellationReasonSheet> {
  static const List<String> _reasons = <String>[
    'Passenger no-show',
    'Wrong pickup location',
    'Emergency / Safety concern',
    'Vehicle issue',
  ];

  String _selectedReason = _reasons.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.neutralCCC,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Select Cancellation Reason',
              style: TextStyle(
                fontSize: 32 / 2,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral333,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'PROFESSIONAL STANDARDS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.emerald,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 22),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (String? value) {
                if (value == null) return;
                setState(() => _selectedReason = value);
              },
              child: Column(
                children: _reasons
                    .map(_buildReasonTile)
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cancellation Fee: \u20B900.00',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.neutral888,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'CONFIRM CANCELLATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            reason,
            style: const TextStyle(
              fontSize: 19 / 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral444,
            ),
          ),
          trailing: Radio<String>(
            value: reason,
            activeColor: AppColors.emerald,
          ),
          onTap: () => setState(() => _selectedReason = reason),
        ),
        const Divider(height: 1, color: AppColors.strokeLight),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceF5,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset('assets/image/profile.png', fit: BoxFit.cover),
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
                    fontSize: 26 / 2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral333,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Icon(Icons.star, size: 12, color: AppColors.starYellow),
                    SizedBox(width: 4),
                    Text(
                      '4.9  Rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral666,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _CircleIconButton(icon: Icons.chat_bubble_outline),
          const SizedBox(width: 8),
          _CircleIconButton(icon: Icons.call),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.neutral555),
    );
  }
}

class _TripMetrics extends StatelessWidget {
  const _TripMetrics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        _MetricItem(label: 'Fare', value: '\u20B91,250'),
        _MetricDivider(),
        _MetricItem(label: 'Distance', value: '2.1 km'),
        _MetricDivider(),
        _MetricItem(label: 'Arrival', value: '4 mins'),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.surfaceF0,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.neutral888,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16 / 1.05,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral333,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupDropSection extends StatelessWidget {
  const _PickupDropSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 20,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 2),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.surfaceFDF8,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emerald, width: 1.5),
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
                  fontSize: 21 / 2,
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
                '13, vinobaji St, KamarajarNagar, NGO...',
                style: TextStyle(
                  fontSize: 21 / 2,
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
