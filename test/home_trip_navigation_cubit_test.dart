import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/features/home/presentation/cubit/trip_navigation_cubit.dart';

void main() {
  group('TripNavigationCubit', () {
    late TripNavigationCubit cubit;
    const path = <LatLng>[
      LatLng(10, 10),
      LatLng(20, 20),
      LatLng(30, 30),
    ];
    const alignPath = <Alignment>[
      Alignment(-1, -1),
      Alignment(0, 0),
      Alignment(1, 1),
    ];

    setUp(() {
      cubit = TripNavigationCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('starts at beginning of route', () {
      expect(cubit.state.progress, 0);
      expect(cubit.state.remainingMeters, 400);
      expect(cubit.currentRoutePoints(path).first, const LatLng(10, 10));
      expect(cubit.bikeAlignment(alignPath), const Alignment(-1, -1));
    });

    test('start progresses over time', () async {
      cubit.start();
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(cubit.state.progress, greaterThan(0));
      expect(cubit.state.showArrivalSheet, isFalse);
      expect(cubit.state.remainingMeters, lessThan(400));
    });
  });
}
