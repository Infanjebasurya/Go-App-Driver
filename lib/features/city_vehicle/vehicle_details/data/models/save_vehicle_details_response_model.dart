class SaveVehicleDetailsResponseModel {
  const SaveVehicleDetailsResponseModel({
    this.message,
    this.success,
    this.vehicleId,
    this.status,
  });

  final String? message;
  final bool? success;
  final String? vehicleId;
  final String? status;

  factory SaveVehicleDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return SaveVehicleDetailsResponseModel(
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
      vehicleId: (json['vehicle_id'] ?? json['vehicleId'] ?? json['id'])
          ?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      if (success != null) 'success': success,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (status != null) 'status': status,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'success') return true;
      if (normalized == 'false' || normalized == 'failed') return false;
    }
    return null;
  }
}

