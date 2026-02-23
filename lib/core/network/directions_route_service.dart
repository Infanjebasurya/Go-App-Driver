import 'package:dio/dio.dart';
import 'package:goapp/core/maps/map_types.dart';

class DirectionsRouteService {
  DirectionsRouteService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<LatLng>?> fetchDrivingRoute({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
    bool preferDetailedSteps = true,
  }) async {
    if (apiKey.isEmpty) return null;

    try {
      final Response<dynamic> response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: <String, dynamic>{
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': apiKey,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      if (data['status'] != 'OK') return null;
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) return null;
      final firstRoute = routes.first;
      if (firstRoute is! Map<String, dynamic>) return null;

      if (preferDetailedSteps) {
        final List<LatLng> stepPoints = decodeStepsPolyline(firstRoute);
        if (stepPoints.length > 1) {
          return dedupeSequential(stepPoints);
        }
      }

      final overview = firstRoute['overview_polyline'];
      if (overview is! Map<String, dynamic>) return null;
      final points = overview['points'];
      if (points is! String || points.isEmpty) return null;
      return decodePolyline(points);
    } catch (_) {
      return null;
    }
  }

  List<LatLng> decodeStepsPolyline(Map<String, dynamic> route) {
    final List<LatLng> path = <LatLng>[];
    final legs = route['legs'];
    if (legs is! List || legs.isEmpty) return path;

    for (final leg in legs) {
      if (leg is! Map<String, dynamic>) continue;
      final steps = leg['steps'];
      if (steps is! List) continue;
      for (final step in steps) {
        if (step is! Map<String, dynamic>) continue;
        final polyline = step['polyline'];
        if (polyline is! Map<String, dynamic>) continue;
        final points = polyline['points'];
        if (points is! String || points.isEmpty) continue;
        path.addAll(decodePolyline(points));
      }
    }
    return path;
  }

  List<LatLng> dedupeSequential(List<LatLng> points) {
    if (points.isEmpty) return points;
    final List<LatLng> out = <LatLng>[points.first];
    for (int i = 1; i < points.length; i++) {
      final prev = out.last;
      final cur = points[i];
      if (prev.latitude == cur.latitude && prev.longitude == cur.longitude) {
        continue;
      }
      out.add(cur);
    }
    return out;
  }

  List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        if (index >= encoded.length) return points;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        if (index >= encoded.length) return points;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
