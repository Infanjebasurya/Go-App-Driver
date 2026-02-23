import 'package:goapp/features/ride_complete/domain/entities/ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_feedback.dart';

abstract class RideCompleteRepository {
  RideCompletionSummary getRideCompletionSummary();

  List<String> getFeedbackTags();

  Future<void> submitFeedback(RideFeedback feedback);
}
