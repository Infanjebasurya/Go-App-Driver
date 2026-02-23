import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_feedback.dart';
import 'package:goapp/features/ride_complete/domain/usecases/get_feedback_tags.dart';
import 'package:goapp/features/ride_complete/domain/usecases/submit_ride_feedback.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/rate_experience_state.dart';

class RateExperienceCubit extends Cubit<RateExperienceState> {
  RateExperienceCubit(GetFeedbackTags getFeedbackTags, this._submitRideFeedback)
    : super(RateExperienceState(feedbackTags: getFeedbackTags()));

  final SubmitRideFeedback _submitRideFeedback;

  void selectRating(int rating) {
    emit(state.copyWith(selectedRating: rating));
  }

  void toggleTag(String tag) {
    final Set<String> updatedTags = Set<String>.from(state.selectedTags);
    if (updatedTags.contains(tag)) {
      updatedTags.remove(tag);
    } else {
      updatedTags.add(tag);
    }
    emit(state.copyWith(selectedTags: updatedTags));
  }

  void updateComment(String comment) {
    emit(state.copyWith(comment: comment));
  }

  Future<void> submitFeedback() {
    return _submitRideFeedback(
      RideFeedback(
        rating: state.selectedRating,
        tags: state.selectedTags,
        comment: state.comment,
      ),
    );
  }
}
