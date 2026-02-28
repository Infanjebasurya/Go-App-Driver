import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_state.dart';

class TripNavigationCubit extends Cubit<TripNavigationState> {
  TripNavigationCubit() : super(const TripNavigationState());

  static const Duration _tickDuration = Duration(milliseconds: 100);
  static const Duration _travelDuration = Duration(seconds: 10);
  Timer? _timer;
  int? _tripStartEpochMs;
  int _pausedAccumulatedMs = 0;
  int? _pausedAtEpochMs;
  int _cachedRouteHash = 0;
  List<double> _cachedCumulative = const <double>[];
  double _cachedTotalDistance = 0;

  void start({int? startedAtEpochMs}) {
    _timer?.cancel();
    _tripStartEpochMs =
        startedAtEpochMs ?? DateTime.now().millisecondsSinceEpoch;
    _pausedAccumulatedMs = 0;
    _pausedAtEpochMs = null;
    _emitProgressFromClock();

    _timer = Timer.periodic(_tickDuration, (_) {
      _emitProgressFromClock();
    });
  }

  void syncWithNow() {
    _emitProgressFromClock();
  }

  void setPaused(bool paused) {
    if (state.showArrivalSheet) return;
    if (paused == state.isPaused) return;

    if (paused) {
      _pausedAtEpochMs = DateTime.now().millisecondsSinceEpoch;
      emit(state.copyWith(isPaused: true));
      return;
    }

    final int pausedAt = _pausedAtEpochMs ?? DateTime.now().millisecondsSinceEpoch;
    _pausedAccumulatedMs += DateTime.now().millisecondsSinceEpoch - pausedAt;
    _pausedAtEpochMs = null;
    emit(state.copyWith(isPaused: false));
    _emitProgressFromClock();
  }

  void markArrived() {
    if (state.showArrivalSheet) return;
    _timer?.cancel();
    emit(state.copyWith(showArrivalSheet: true, isPaused: false));
  }

  void _emitProgressFromClock() {
    final int? startedMs = _tripStartEpochMs;
    if (startedMs == null) return;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final int activePauseMs = state.isPaused && _pausedAtEpochMs != null
        ? (nowMs - _pausedAtEpochMs!)
        : 0;
    final int elapsedMs =
        nowMs - startedMs - _pausedAccumulatedMs - activePauseMs;
    final double nextProgress = (elapsedMs / _travelDuration.inMilliseconds)
        .clamp(0, 1);

    if (nextProgress < 1) {
      emit(state.copyWith(progress: nextProgress));
      return;
    }
    emit(
      const TripNavigationState(
        progress: 1,
        showArrivalSheet: true,
        isPaused: false,
      ),
    );
    _timer?.cancel();
  }

  Alignment bikeAlignment(List<Alignment> path) {
    if (path.isEmpty) return Alignment.center;
    if (path.length == 1) return path.first;

    final double progress = state.progress.clamp(0, 1);
    if (progress <= 0) return path.first;
    if (progress >= 1) return path.last;

    final int segmentCount = path.length - 1;
    final double segmentProgress = progress * segmentCount;
    final int segmentIndex = segmentProgress.floor().clamp(0, segmentCount - 1);
    final double localT = segmentProgress - segmentIndex;

    return Alignment.lerp(path[segmentIndex], path[segmentIndex + 1], localT) ??
        path.last;
  }

  LatLng pointAlongRoute(List<LatLng> path) {
    if (path.isEmpty) return const LatLng(0, 0);
    if (path.length == 1) return path.first;

    final double progress = state.progress.clamp(0, 1);
    if (progress <= 0) return path.first;
    if (progress >= 1) return path.last;

    _ensureRouteCache(path);
    if (_cachedTotalDistance <= 0 || _cachedCumulative.isEmpty) {
      return path.last;
    }
    final double targetDistance = _cachedTotalDistance * progress;
    final int segmentIndex = _segmentIndexAtDistance(
      _cachedCumulative,
      targetDistance,
    );

    final double segmentStart = _cachedCumulative[segmentIndex - 1];
    final double segmentEnd = _cachedCumulative[segmentIndex];
    final double segmentLength = segmentEnd - segmentStart;
    if (segmentLength <= 0) return path[segmentIndex];
    final double localT = (targetDistance - segmentStart) / segmentLength;

    final LatLng from = path[segmentIndex - 1];
    final LatLng to = path[segmentIndex];
    return LatLng(
      from.latitude + ((to.latitude - from.latitude) * localT.clamp(0, 1)),
      from.longitude + ((to.longitude - from.longitude) * localT.clamp(0, 1)),
    );
  }

  List<LatLng> currentRoutePoints(List<LatLng> path) {
    if (path.isEmpty) return const <LatLng>[];
    if (path.length == 1 || state.progress >= 1) return <LatLng>[path.last];

    _ensureRouteCache(path);
    final double targetDistance =
        _cachedTotalDistance * state.progress.clamp(0, 1);
    final int segmentIndex = _segmentIndexAtDistance(
      _cachedCumulative,
      targetDistance,
    );
    final LatLng currentPoint = pointAlongRoute(path);

    return <LatLng>[currentPoint, ...path.sublist(segmentIndex)];
  }

  void _ensureRouteCache(List<LatLng> path) {
    final int hash = Object.hashAll(path);
    if (hash == _cachedRouteHash &&
        _cachedCumulative.isNotEmpty &&
        _cachedCumulative.length == path.length) {
      return;
    }
    _cachedRouteHash = hash;
    _cachedCumulative = _cumulativeDistances(path);
    _cachedTotalDistance = _cachedCumulative.isEmpty
        ? 0
        : _cachedCumulative.last;
  }

  List<double> _cumulativeDistances(List<LatLng> path) {
    final List<double> cumulative = List<double>.filled(path.length, 0);
    double total = 0;
    for (int i = 1; i < path.length; i++) {
      total += _distanceMeters(path[i - 1], path[i]);
      cumulative[i] = total;
    }
    return cumulative;
  }

  int _segmentIndexAtDistance(List<double> cumulative, double targetDistance) {
    int index = 1;
    while (index < cumulative.length && cumulative[index] < targetDistance) {
      index++;
    }
    return index.clamp(1, cumulative.length - 1);
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
  Future<void> close() async {
    _timer?.cancel();
    await super.close();
  }
}
