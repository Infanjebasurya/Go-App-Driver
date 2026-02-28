import 'package:goapp/core/storage/ride_history_store.dart';

enum RideHistoryFilter { all, completed, inProgress, canceled }

enum RideHistorySort { latestFirst, oldestFirst }

class RideHistoryState {
  const RideHistoryState({
    required this.allTrips,
    required this.visibleTrips,
    required this.isLoading,
    required this.filter,
    required this.sort,
    required this.searchQuery,
    required this.expandedTripIds,
  });

  factory RideHistoryState.initial() {
    return const RideHistoryState(
      allTrips: <RideHistoryTrip>[],
      visibleTrips: <RideHistoryTrip>[],
      isLoading: true,
      filter: RideHistoryFilter.all,
      sort: RideHistorySort.latestFirst,
      searchQuery: '',
      expandedTripIds: <String>{},
    );
  }

  final List<RideHistoryTrip> allTrips;
  final List<RideHistoryTrip> visibleTrips;
  final bool isLoading;
  final RideHistoryFilter filter;
  final RideHistorySort sort;
  final String searchQuery;
  final Set<String> expandedTripIds;

  RideHistoryState copyWith({
    List<RideHistoryTrip>? allTrips,
    List<RideHistoryTrip>? visibleTrips,
    bool? isLoading,
    RideHistoryFilter? filter,
    RideHistorySort? sort,
    String? searchQuery,
    Set<String>? expandedTripIds,
  }) {
    return RideHistoryState(
      allTrips: allTrips ?? this.allTrips,
      visibleTrips: visibleTrips ?? this.visibleTrips,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedTripIds: expandedTripIds ?? this.expandedTripIds,
    );
  }
}
