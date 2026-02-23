import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/home/data/models/captain_profile_model.dart';
import 'package:goapp/features/home/domain/entities/captain_profile.dart';

void main() {
  group('CaptainProfileModel', () {
    test('fromJson parses API fields correctly', () {
      final model = CaptainProfileModel.fromJson(<String, dynamic>{
        'id': 'captain-101',
        'name': 'Sybrox Captain',
        'vehicle_type': 'Bike',
        'is_online': true,
      });

      expect(model.id, 'captain-101');
      expect(model.name, 'Sybrox Captain');
      expect(model.vehicleType, 'Bike');
      expect(model.isOnline, isTrue);
    });

    test('is a CaptainProfile entity', () {
      const model = CaptainProfileModel(
        id: 'captain-1',
        name: 'Name',
        vehicleType: 'Bike',
        isOnline: false,
      );

      expect(model, isA<CaptainProfile>());
    });
  });
}
