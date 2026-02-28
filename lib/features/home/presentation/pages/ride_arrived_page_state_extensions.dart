part of 'ride_arrived_page.dart';

extension _RideArrivedPageStateExtensions on _RideArrivedPageState {
  double _metersToPickup() {
    return _distanceMeters(_driverPoint, widget.pickupPoint);
  }

  bool _canProceedToRideCode() {
    return _locationIssue == null && _metersToPickup() <= 100;
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
}
