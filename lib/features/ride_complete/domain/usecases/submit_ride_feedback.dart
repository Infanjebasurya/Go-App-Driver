import 'package:goapp/features/ride_complete/domain/entities/ride_feedback.dart';
import 'package:goapp/features/ride_complete/domain/repositories/ride_complete_repository.dart';

class SubmitRideFeedback {
  const SubmitRideFeedback(this._repository);

  final RideCompleteRepository _repository;

  Future<void> call(RideFeedback feedback) {
    return _repository.submitFeedback(feedback);
  }
}
