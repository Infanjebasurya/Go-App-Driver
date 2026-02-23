import 'package:equatable/equatable.dart';

enum RateAppStatus { idle, submitting, submitted, error }

class RateAppState extends Equatable {
  final int selectedRating;
  final String feedbackText;
  final RateAppStatus status;
  final String? errorMessage;

  const RateAppState({
    this.selectedRating = 0,
    this.feedbackText = '',
    this.status = RateAppStatus.idle,
    this.errorMessage,
  });

  bool get canSubmit => selectedRating > 0;

  RateAppState copyWith({
    int? selectedRating,
    String? feedbackText,
    RateAppStatus? status,
    String? errorMessage,
  }) {
    return RateAppState(
      selectedRating: selectedRating ?? this.selectedRating,
      feedbackText: feedbackText ?? this.feedbackText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [selectedRating, feedbackText, status, errorMessage];
}
