class SaveVehicleDetailsRequestModel {
  const SaveVehicleDetailsRequestModel({
    required this.vehicleType,
    required this.modelName,
    required this.fuelType,
    required this.year,
    required this.photoPath,
    this.bikeType,
    this.seatOption,
  });

  final String vehicleType;
  final String modelName;
  final String fuelType;
  final String year;
  final String photoPath;
  final String? bikeType;
  final String? seatOption;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'vehicle_type': vehicleType,
      'model_name': modelName,
      'fuel_type': fuelType,
      'year': year,
      'photo_path': photoPath,
      if (bikeType != null) 'bike_type': bikeType,
      if (seatOption != null) 'seat_option': seatOption,
    };
  }
}
