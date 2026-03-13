class SendOtpResponseModel {
  const SendOtpResponseModel({required this.otpId, this.message, this.success});

  final String otpId;
  final String? message;
  final bool? success;

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic otpIdRaw = json['otp_id'] ?? json['otpId'] ?? json['id'];
    return SendOtpResponseModel(
      otpId: (otpIdRaw ?? '').toString(),
      message: (json['message'] ?? json['msg'])?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'otp_id': otpId,
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
