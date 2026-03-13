class UploadProfileImageRequestModel {
  const UploadProfileImageRequestModel({required this.filePath, this.fileName});

  final String filePath;
  final String? fileName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'file_path': filePath,
      if (fileName != null) 'file_name': fileName,
    };
  }
}

class UploadDrivingLicenseRequestModel {
  const UploadDrivingLicenseRequestModel({
    required this.frontFilePath,
    required this.backFilePath,
    required this.licenseNumber,
  });

  final String frontFilePath;
  final String backFilePath;
  final String licenseNumber;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'front_file_path': frontFilePath,
      'back_file_path': backFilePath,
      'license_number': licenseNumber,
    };
  }
}

class UploadVehicleRcRequestModel {
  const UploadVehicleRcRequestModel({
    required this.frontFilePath,
    required this.backFilePath,
    required this.vehicleNumber,
  });

  final String frontFilePath;
  final String backFilePath;
  final String vehicleNumber;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'front_file_path': frontFilePath,
      'back_file_path': backFilePath,
      'vehicle_number': vehicleNumber,
    };
  }
}

class UploadAadhaarRequestModel {
  const UploadAadhaarRequestModel({
    required this.frontFilePath,
    required this.backFilePath,
    required this.aadhaarNumber,
  });

  final String frontFilePath;
  final String backFilePath;
  final String aadhaarNumber;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'front_file_path': frontFilePath,
      'back_file_path': backFilePath,
      'aadhaar_number': aadhaarNumber,
    };
  }
}

class UploadPanRequestModel {
  const UploadPanRequestModel({
    required this.frontFilePath,
    required this.panNumber,
  });

  final String frontFilePath;
  final String panNumber;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'front_file_path': frontFilePath,
      'pan_number': panNumber,
    };
  }
}
