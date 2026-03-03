class VehicleTypeItemModel {
  const VehicleTypeItemModel({
    required this.code,
    required this.label,
    this.tier,
    this.seatsDescription,
    this.iconKey,
  });

  final String code;
  final String label;
  final String? tier;
  final String? seatsDescription;
  final String? iconKey;

  factory VehicleTypeItemModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeItemModel(
      code: (json['code'] ?? json['type'] ?? json['id'] ?? '').toString(),
      label: (json['label'] ?? json['name'] ?? '').toString(),
      tier: (json['tier'] ?? json['category'])?.toString(),
      seatsDescription: (json['seats_description'] ?? json['seatsDescription'])
          ?.toString(),
      iconKey: (json['icon_key'] ?? json['iconKey'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'label': label,
      if (tier != null) 'tier': tier,
      if (seatsDescription != null) 'seats_description': seatsDescription,
      if (iconKey != null) 'icon_key': iconKey,
    };
  }
}

class GetVehicleTypesResponseModel {
  const GetVehicleTypesResponseModel({
    required this.vehicleTypes,
    this.message,
    this.success,
  });

  final List<VehicleTypeItemModel> vehicleTypes;
  final String? message;
  final bool? success;

  factory GetVehicleTypesResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic listRaw =
        json['data'] ?? json['vehicle_types'] ?? json['vehicleTypes'] ?? json['types'];
    final List<VehicleTypeItemModel> parsedTypes =
        (listRaw is List<dynamic> ? listRaw : const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(VehicleTypeItemModel.fromJson)
            .toList(growable: false);

    return GetVehicleTypesResponseModel(
      vehicleTypes: parsedTypes,
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'data': vehicleTypes.map((e) => e.toJson()).toList(growable: false),
      if (message != null) 'message': message,
      if (success != null) 'success': success,
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

