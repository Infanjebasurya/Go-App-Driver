import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/features/ride_history/data/datasources/ride_history_mock_api.dart';
import 'package:goapp/features/ride_history/domain/repositories/ride_history_repository.dart';

class RideHistoryRepositoryImpl implements RideHistoryRepository {
  const RideHistoryRepositoryImpl({RideHistoryMockApi? api})
    : _api = api ?? const RideHistoryMockApi();

  final RideHistoryMockApi _api;

  @override
  Future<List<RideHistoryTrip>> getHistory() {
    return _api.fetchRideHistory();
  }
}
