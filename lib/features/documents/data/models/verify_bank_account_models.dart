class VerifyBankAccountRequestModel {
  const VerifyBankAccountRequestModel({
    required this.accountNumber,
    required this.ifscCode,
    this.accountHolderName,
  });

  final String accountNumber;
  final String ifscCode;
  final String? accountHolderName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
    };
  }
}

class VerifyBankAccountResponseModel {
  const VerifyBankAccountResponseModel({
    this.message,
    this.success,
    this.verified,
    this.pennyDropReferenceId,
    this.accountHolderNameMatch,
    this.status,
  });

  final String? message;
  final bool? success;
  final bool? verified;
  final String? pennyDropReferenceId;
  final bool? accountHolderNameMatch;
  final String? status;

  factory VerifyBankAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyBankAccountResponseModel(
      message: json['message']?.toString(),
      success: _parseBool(json['success']),
      verified: _parseBool(json['verified'] ?? json['is_verified']),
      pennyDropReferenceId:
          (json['penny_drop_reference_id'] ??
                  json['pennyDropReferenceId'] ??
                  json['reference_id'])
              ?.toString(),
      accountHolderNameMatch: _parseBool(
        json['account_holder_name_match'] ?? json['accountHolderNameMatch'],
      ),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      if (success != null) 'success': success,
      if (verified != null) 'verified': verified,
      if (pennyDropReferenceId != null)
        'penny_drop_reference_id': pennyDropReferenceId,
      if (accountHolderNameMatch != null)
        'account_holder_name_match': accountHolderNameMatch,
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
