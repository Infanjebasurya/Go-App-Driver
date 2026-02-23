import 'package:goapp/features/home/data/models/captain_profile_model.dart';

abstract interface class CaptainRemoteDataSource {
  Future<CaptainProfileModel> fetchCaptainProfile();
}

class CaptainRemoteDataSourceImpl implements CaptainRemoteDataSource {
  @override
  Future<CaptainProfileModel> fetchCaptainProfile() async {
    final Map<String, dynamic> mockResponse = <String, dynamic>{
      'id': 'captain-101',
      'name': 'Sybrox Captain',
      'vehicle_type': 'Bike',
      'is_online': true,
    };
    return CaptainProfileModel.fromJson(mockResponse);
  }
}
