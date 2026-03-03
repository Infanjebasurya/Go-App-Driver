class BankDetailsModel {
  const BankDetailsModel({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    this.branchName,
  });

  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String? branchName;

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      accountHolderName:
          (json['account_holder_name'] ?? json['accountHolderName'] ?? '')
              .toString(),
      bankName: (json['bank_name'] ?? json['bankName'] ?? '').toString(),
      accountNumber:
          (json['account_number'] ?? json['accountNumber'] ?? '').toString(),
      ifscCode: (json['ifsc_code'] ?? json['ifscCode'] ?? '').toString(),
      branchName: (json['branch_name'] ?? json['branchName'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      if (branchName != null) 'branch_name': branchName,
    };
  }
}

class SaveBankDetailsRequestModel {
  const SaveBankDetailsRequestModel({
    required this.bankDetails,
  });

  final BankDetailsModel bankDetails;

  Map<String, dynamic> toJson() {
    return bankDetails.toJson();
  }
}

class SaveBankDetailsResponseModel {
  const SaveBankDetailsResponseModel({
    this.message,
    this.success,
    this.bankDetailsId,
    this.status,
    this.bankDetails,
  });

  final String? message;
  final bool? success;
  final String? bankDetailsId;
  final String? status;
  final BankDetailsModel? bankDetails;

  factory SaveBankDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic detailsRaw = json['bank_details'] ?? json['bankDetails'];
    return SaveBankDetailsResponseModel(
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
      bankDetailsId:
          (json['bank_details_id'] ?? json['bankDetailsId'] ?? json['id'])
              ?.toString(),
      status: json['status']?.toString(),
      bankDetails: detailsRaw is Map<String, dynamic>
          ? BankDetailsModel.fromJson(detailsRaw)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (message != null) 'message': message,
      if (success != null) 'success': success,
      if (bankDetailsId != null) 'bank_details_id': bankDetailsId,
      if (status != null) 'status': status,
      if (bankDetails != null) 'bank_details': bankDetails!.toJson(),
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

