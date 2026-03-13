import 'package:goapp/features/documents/data/models/document_upload_response_model.dart';

class UploadProfileImageResponseModel extends DocumentUploadResponseModel {
  const UploadProfileImageResponseModel({
    super.documentId,
    super.fileUrl,
    super.status,
    super.message,
    super.success,
  });

  factory UploadProfileImageResponseModel.fromJson(Map<String, dynamic> json) {
    final base = DocumentUploadResponseModel.fromJson(json);
    return UploadProfileImageResponseModel(
      documentId: base.documentId,
      fileUrl: base.fileUrl,
      status: base.status,
      message: base.message,
      success: base.success,
    );
  }
}

class UploadDrivingLicenseResponseModel extends DocumentUploadResponseModel {
  const UploadDrivingLicenseResponseModel({
    super.documentId,
    super.fileUrl,
    super.status,
    super.message,
    super.success,
  });

  factory UploadDrivingLicenseResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final base = DocumentUploadResponseModel.fromJson(json);
    return UploadDrivingLicenseResponseModel(
      documentId: base.documentId,
      fileUrl: base.fileUrl,
      status: base.status,
      message: base.message,
      success: base.success,
    );
  }
}

class UploadVehicleRcResponseModel extends DocumentUploadResponseModel {
  const UploadVehicleRcResponseModel({
    super.documentId,
    super.fileUrl,
    super.status,
    super.message,
    super.success,
  });

  factory UploadVehicleRcResponseModel.fromJson(Map<String, dynamic> json) {
    final base = DocumentUploadResponseModel.fromJson(json);
    return UploadVehicleRcResponseModel(
      documentId: base.documentId,
      fileUrl: base.fileUrl,
      status: base.status,
      message: base.message,
      success: base.success,
    );
  }
}

class UploadAadhaarResponseModel extends DocumentUploadResponseModel {
  const UploadAadhaarResponseModel({
    super.documentId,
    super.fileUrl,
    super.status,
    super.message,
    super.success,
  });

  factory UploadAadhaarResponseModel.fromJson(Map<String, dynamic> json) {
    final base = DocumentUploadResponseModel.fromJson(json);
    return UploadAadhaarResponseModel(
      documentId: base.documentId,
      fileUrl: base.fileUrl,
      status: base.status,
      message: base.message,
      success: base.success,
    );
  }
}

class UploadPanResponseModel extends DocumentUploadResponseModel {
  const UploadPanResponseModel({
    super.documentId,
    super.fileUrl,
    super.status,
    super.message,
    super.success,
  });

  factory UploadPanResponseModel.fromJson(Map<String, dynamic> json) {
    final base = DocumentUploadResponseModel.fromJson(json);
    return UploadPanResponseModel(
      documentId: base.documentId,
      fileUrl: base.fileUrl,
      status: base.status,
      message: base.message,
      success: base.success,
    );
  }
}
