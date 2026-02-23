import 'package:goapp/features/ride_complete/domain/entities/ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/domain/repositories/ride_complete_repository.dart';

class GetRideCompletionSummary {
  const GetRideCompletionSummary(this._repository);

  final RideCompleteRepository _repository;

  RideCompletionSummary call() {
    return _repository.getRideCompletionSummary();
  }
}
