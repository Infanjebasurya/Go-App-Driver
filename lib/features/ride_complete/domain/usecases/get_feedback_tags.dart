import 'package:goapp/features/ride_complete/domain/repositories/ride_complete_repository.dart';

class GetFeedbackTags {
  const GetFeedbackTags(this._repository);

  final RideCompleteRepository _repository;

  List<String> call() {
    return _repository.getFeedbackTags();
  }
}
