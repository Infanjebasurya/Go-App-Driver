class VerificationDocumentStatusItemModel {
  const VerificationDocumentStatusItemModel({
    required this.code,
    required this.status,
    this.message,
  });

  final String code;
  final String status;
  final String? message;

  factory VerificationDocumentStatusItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VerificationDocumentStatusItemModel(
      code: (json['code'] ?? json['document_type'] ?? json['type'] ?? '')
          .toString(),
      status: (json['status'] ?? 'pending').toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'status': status,
      if (message != null) 'message': message,
    };
  }
}

class GetVerificationStatusResponseModel {
  const GetVerificationStatusResponseModel({
    required this.documents,
    this.profileImageUploaded,
    this.overallStatus,
    this.message,
    this.success,
  });

  final List<VerificationDocumentStatusItemModel> documents;
  final bool? profileImageUploaded;
  final String? overallStatus;
  final String? message;
  final bool? success;

  factory GetVerificationStatusResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic docsRaw =
        json['documents'] ?? json['data'] ?? json['items'] ?? const <dynamic>[];
    final documents = (docsRaw is List<dynamic> ? docsRaw : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(VerificationDocumentStatusItemModel.fromJson)
        .toList(growable: false);

    return GetVerificationStatusResponseModel(
      documents: documents,
      profileImageUploaded: _parseBool(
        json['profile_image_uploaded'] ?? json['profileImageUploaded'],
      ),
      overallStatus: (json['overall_status'] ?? json['overallStatus'])
          ?.toString(),
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'documents': documents.map((e) => e.toJson()).toList(growable: false),
      if (profileImageUploaded != null)
        'profile_image_uploaded': profileImageUploaded,
      if (overallStatus != null) 'overall_status': overallStatus,
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

