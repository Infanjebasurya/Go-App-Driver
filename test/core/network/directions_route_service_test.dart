import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/network/directions_route_service.dart';

void main() {
  group('DirectionsRouteService', () {
    final service = DirectionsRouteService();

    test('decodePolyline decodes known sample', () {
      // Polyline for points: (38.5,-120.2), (40.7,-120.95), (43.252,-126.453)
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = service.decodePolyline(encoded);

      expect(points.length, 3);
      expect(points[0].latitude, closeTo(38.5, 0.0001));
      expect(points[0].longitude, closeTo(-120.2, 0.0001));
      expect(points[2].latitude, closeTo(43.252, 0.0001));
      expect(points[2].longitude, closeTo(-126.453, 0.0001));
    });

    test('dedupeSequential removes adjacent duplicates only', () {
      final points = service.decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
      final deduped = service.dedupeSequential(<LatLng>[
        points[0],
        points[0],
        points[1],
        points[1],
        points[2],
      ]);

      expect(deduped.length, 3);
      expect(deduped.first, points.first);
      expect(deduped.last, points.last);
    });

    test('decodeStepsPolyline aggregates all step polylines', () {
      const encodedA = '_p~iF~ps|U_ulLnnqC';
      const encodedB = '_mqNvxq`@';
      final route = <String, dynamic>{
        'legs': <dynamic>[
          <String, dynamic>{
            'steps': <dynamic>[
              <String, dynamic>{
                'polyline': <String, dynamic>{'points': encodedA},
              },
              <String, dynamic>{
                'polyline': <String, dynamic>{'points': encodedB},
              },
            ],
          },
        ],
      };

      final result = service.decodeStepsPolyline(route);
      expect(result, isNotEmpty);
    });
  });
}
