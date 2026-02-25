import 'package:equatable/equatable.dart';

enum DocumentStatus { completed, required, pending, uploading }

enum DocumentType {
  drivingLicense,
  vehicleRC,
  aadhaarCard,
  panCard,
  bankDetails,
}

class Document extends Equatable {
  const Document({
    required this.type,
    required this.status,
    this.filePath,
    this.bankDetails,  // ✅ only populated for bankDetails type
  });

  final DocumentType type;
  final DocumentStatus status;
  final String? filePath;
  final BankDetails? bankDetails; // ✅ stores bank info after user fills form

  String get title {
    switch (type) {
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.vehicleRC:
        return 'Vehicle RC';
      case DocumentType.aadhaarCard:
        return 'Aadhaar Card';
      case DocumentType.panCard:
        return 'PAN Card';
      case DocumentType.bankDetails:
        return 'Bank Details';
    }
  }

  bool get isCompleted => status == DocumentStatus.completed;
  bool get isRequired => status == DocumentStatus.required;
  bool get isUploading => status == DocumentStatus.uploading;

  Document copyWith({
    DocumentType? type,
    DocumentStatus? status,
    String? filePath,
    BankDetails? bankDetails,
    bool clearBankDetails = false,
  }) {
    return Document(
      type: type ?? this.type,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      bankDetails: clearBankDetails ? null : (bankDetails ?? this.bankDetails),
    );
  }

  @override
  List<Object?> get props => [type, status, filePath, bankDetails];
}

// ✅ Separate model to hold bank details data
class BankDetails extends Equatable {
  const BankDetails({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
  });

  final String accountHolderName;
  final String bankName;
  final String accountNumber;   // ✅ stored (never store confirm separately)
  final String ifscCode;

  BankDetails copyWith({
    String? accountHolderName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) {
    return BankDetails(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
    );
  }

  @override
  List<Object?> get props => [
    accountHolderName,
    bankName,
    accountNumber,
    ifscCode,
  ];
}