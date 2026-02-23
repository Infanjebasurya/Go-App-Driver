import 'package:goapp/features/home/domain/entities/captain_profile.dart';

class CaptainProfileModel extends CaptainProfile {
  const CaptainProfileModel({
    required super.id,
    required super.name,
    required super.vehicleType,
    required super.isOnline,
  });

  factory CaptainProfileModel.fromJson(Map<String, dynamic> json) {
    return CaptainProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      vehicleType: json['vehicle_type'] as String,
      isOnline: json['is_online'] as bool,
    );
  }
}
