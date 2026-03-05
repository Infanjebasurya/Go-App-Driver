import 'package:goapp/core/storage/ride_history_store.dart';

abstract interface class RideHistoryRepository {
  Future<List<RideHistoryTrip>> getHistory();
}
