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
  final DocumentType type;
  final DocumentStatus status;
  final String? filePath;

  const Document({required this.type, required this.status, this.filePath});

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
  }) {
    return Document(
      type: type ?? this.type,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  List<Object?> get props => [type, status, filePath];
}

class VerificationState extends Equatable {
  final List<Document> documents;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  const VerificationState({
    required this.documents,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  factory VerificationState.initial() {
    return const VerificationState(
      documents: [
        Document(
          type: DocumentType.drivingLicense,
          status: DocumentStatus.required,
        ),
        Document(type: DocumentType.vehicleRC, status: DocumentStatus.required),
        Document(
          type: DocumentType.aadhaarCard,
          status: DocumentStatus.required,
        ),
        Document(type: DocumentType.panCard, status: DocumentStatus.required),
        Document(
          type: DocumentType.bankDetails,
          status: DocumentStatus.required,
        ),
      ],
    );
  }

  int get completedCount => documents.where((d) => d.isCompleted).length;

  double get progressPercentage =>
      documents.isEmpty ? 0 : completedCount / documents.length;

  int get progressPercent => (progressPercentage * 100).round();

  bool get canSubmit => completedCount == documents.length;

  VerificationState copyWith({
    List<Document>? documents,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VerificationState(
      documents: documents ?? this.documents,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    documents,
    isSubmitting,
    isSubmitted,
    errorMessage,
  ];
}
