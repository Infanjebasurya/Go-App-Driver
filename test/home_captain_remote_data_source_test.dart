import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/home/data/datasources/captain_remote_data_source.dart';
import 'package:goapp/features/home/data/models/captain_profile_model.dart';

void main() {
  group('CaptainRemoteDataSourceImpl', () {
    late CaptainRemoteDataSourceImpl dataSource;

    setUp(() {
      dataSource = CaptainRemoteDataSourceImpl();
    });

    test('fetchCaptainProfile returns the mock profile payload', () async {
      final result = await dataSource.fetchCaptainProfile();

      expect(result, isA<CaptainProfileModel>());
      expect(
        result,
        const CaptainProfileModel(
          id: 'captain-101',
          name: 'Sybrox Captain',
          vehicleType: 'Bike',
          isOnline: true,
        ),
      );
    });
  });
}
