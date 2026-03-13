import 'package:equatable/equatable.dart';

import '../model/document_model.dart';

class VerificationState extends Equatable {
  const VerificationState({
    required this.documents,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
    this.isProfileImageUploaded = false,
  });

  final List<Document> documents;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;
  final bool isProfileImageUploaded;

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
      isProfileImageUploaded: false,
    );
  }

  int get completedCount => documents.where((d) => d.isCompleted).length;

  int get totalRequiredCount => documents.length + 1;

  int get completedCountWithProfile =>
      completedCount + (isProfileImageUploaded ? 1 : 0);

  double get progressPercentage => totalRequiredCount == 0
      ? 0
      : completedCountWithProfile / totalRequiredCount;

  int get progressPercent => (progressPercentage * 100).round();

  bool get canSubmit =>
      isProfileImageUploaded && completedCount == documents.length;

  VerificationState copyWith({
    List<Document>? documents,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    bool? isProfileImageUploaded,
    bool clearError = false,
  }) {
    return VerificationState(
      documents: documents ?? this.documents,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProfileImageUploaded:
          isProfileImageUploaded ?? this.isProfileImageUploaded,
    );
  }

  @override
  List<Object?> get props => [
    documents,
    isSubmitting,
    isSubmitted,
    errorMessage,
    isProfileImageUploaded,
  ];
}
