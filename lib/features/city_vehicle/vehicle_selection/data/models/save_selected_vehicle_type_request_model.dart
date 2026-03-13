class SaveSelectedVehicleTypeRequestModel {
  const SaveSelectedVehicleTypeRequestModel({
    required this.vehicleTypeCode,
    this.cityId,
  });

  final String vehicleTypeCode;
  final String? cityId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'vehicle_type': vehicleTypeCode,
      if (cityId != null) 'city_id': cityId,
    };
  }
}
