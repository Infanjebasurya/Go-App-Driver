import 'package:equatable/equatable.dart';

class RateExperienceState extends Equatable {
  const RateExperienceState({
    this.selectedRating = 4,
    this.selectedTags = const <String>{},
    this.comment = '',
    this.feedbackTags = const <String>[],
  });

  final int selectedRating;
  final Set<String> selectedTags;
  final String comment;
  final List<String> feedbackTags;

  RateExperienceState copyWith({
    int? selectedRating,
    Set<String>? selectedTags,
    String? comment,
    List<String>? feedbackTags,
  }) {
    return RateExperienceState(
      selectedRating: selectedRating ?? this.selectedRating,
      selectedTags: selectedTags ?? this.selectedTags,
      comment: comment ?? this.comment,
      feedbackTags: feedbackTags ?? this.feedbackTags,
    );
  }

  @override
  List<Object> get props => <Object>[
    selectedRating,
    selectedTags,
    comment,
    feedbackTags,
  ];
}
