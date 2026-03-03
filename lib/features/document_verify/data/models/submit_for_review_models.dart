class SubmitForReviewRequestModel {
  const SubmitForReviewRequestModel({
    this.notes,
    this.declarationAccepted = true,
    this.submittedAt,
  });

  final String? notes;
  final bool declarationAccepted;
  final String? submittedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'declaration_accepted': declarationAccepted,
      if (notes != null) 'notes': notes,
      if (submittedAt != null) 'submitted_at': submittedAt,
    };
  }
}

class SubmitForReviewResponseModel {
  const SubmitForReviewResponseModel({
    this.message,
    this.success,
    this.submissionId,
    this.status,
    this.submittedAt,
  });

  final String? message;
  final bool? success;
  final String? submissionId;
  final String? status;
  final String? submittedAt;

  factory SubmitForReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitForReviewResponseModel(
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
      submissionId:
          (json['submission_id'] ?? json['submissionId'] ?? json['id'])
              ?.toString(),
      status: json['status']?.toString(),
      submittedAt: (json['submitted_at'] ?? json['submittedAt'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      if (success != null) 'success': success,
      if (submissionId != null) 'submission_id': submissionId,
      if (status != null) 'status': status,
      if (submittedAt != null) 'submitted_at': submittedAt,
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

