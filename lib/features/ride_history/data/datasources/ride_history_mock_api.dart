import 'package:goapp/core/storage/ride_history_store.dart';

class RideHistoryMockApi {
  const RideHistoryMockApi();

  Future<List<RideHistoryTrip>> fetchRideHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return RideHistoryStore.loadTrips();
  }
}
