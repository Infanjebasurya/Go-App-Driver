import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/features/ride_history/domain/repositories/ride_history_repository.dart';

class GetRideHistoryUseCase {
  const GetRideHistoryUseCase(this._repository);

  final RideHistoryRepository _repository;

  Future<List<RideHistoryTrip>> call() {
    return _repository.getHistory();
  }
}
