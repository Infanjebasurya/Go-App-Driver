import 'package:equatable/equatable.dart';

import '../model/document_model.dart';


class VerificationState extends Equatable {
  const VerificationState({
    required this.documents,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  final List<Document> documents;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  factory VerificationState.initial() {
    return const VerificationState(
      documents: [
        Document(type: DocumentType.drivingLicense, status: DocumentStatus.required),
        Document(type: DocumentType.vehicleRC, status: DocumentStatus.required),
        Document(type: DocumentType.aadhaarCard, status: DocumentStatus.required),
        Document(type: DocumentType.panCard, status: DocumentStatus.required),
        Document(type: DocumentType.bankDetails, status: DocumentStatus.required),
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
