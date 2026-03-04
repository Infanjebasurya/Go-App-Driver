import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/utils/earnings_calculator.dart';
import 'package:goapp/features/ride_history/data/repositories/ride_history_repository_impl.dart';
import 'package:goapp/features/ride_history/domain/usecases/get_ride_history_usecase.dart';
import 'package:goapp/features/ride_history/presentation/cubit/ride_history_state.dart';

class RideHistoryCubit extends Cubit<RideHistoryState> {
  RideHistoryCubit({GetRideHistoryUseCase? getRideHistory})
    : _getRideHistory =
          getRideHistory ??
          GetRideHistoryUseCase(const RideHistoryRepositoryImpl()),
      super(RideHistoryState.initial());

  final GetRideHistoryUseCase _getRideHistory;

  Future<void> loadHistory() async {
    emit(state.copyWith(isLoading: true));
    final List<RideHistoryTrip> loaded = await _getRideHistory();
    final List<RideHistoryTrip> visible = _buildVisibleTrips(
      trips: loaded,
      filter: state.filter,
      sort: state.sort,
      query: state.searchQuery,
    );
    emit(
      state.copyWith(
        allTrips: loaded,
        visibleTrips: visible,
        isLoading: false,
      ),
    );
  }

  void setFilter(RideHistoryFilter filter) {
    final List<RideHistoryTrip> visible = _buildVisibleTrips(
      trips: state.allTrips,
      filter: filter,
      sort: state.sort,
      query: state.searchQuery,
    );
    emit(state.copyWith(filter: filter, visibleTrips: visible));
  }

  void setSort(RideHistorySort sort) {
    final List<RideHistoryTrip> visible = _buildVisibleTrips(
      trips: state.allTrips,
      filter: state.filter,
      sort: sort,
      query: state.searchQuery,
    );
    emit(state.copyWith(sort: sort, visibleTrips: visible));
  }

  void setSearchQuery(String query) {
    final String normalized = query.trim().toLowerCase();
    final List<RideHistoryTrip> visible = _buildVisibleTrips(
      trips: state.allTrips,
      filter: state.filter,
      sort: state.sort,
      query: normalized,
    );
    emit(state.copyWith(searchQuery: normalized, visibleTrips: visible));
  }

  void toggleExpanded(String tripId) {
    final Set<String> next = Set<String>.from(state.expandedTripIds);
    if (next.contains(tripId)) {
      next.remove(tripId);
    } else {
      next.add(tripId);
    }
    emit(state.copyWith(expandedTripIds: next));
  }

  int completedCount() {
    return state.allTrips.where((RideHistoryTrip t) {
      return t.completedAtEpochMs != null && t.canceledAtEpochMs == null;
    }).length;
  }

  int inProgressCount() {
    return state.allTrips.where((RideHistoryTrip t) {
      return t.completedAtEpochMs == null && t.canceledAtEpochMs == null;
    }).length;
  }

  int canceledCount() {
    return state.allTrips
        .where((RideHistoryTrip t) => t.canceledAtEpochMs != null)
        .length;
  }

  double totalEarnings() {
    double sum = 0;
    for (final RideHistoryTrip trip in state.allTrips) {
      if (!EarningsCalculator.isSettledTrip(trip)) continue;
      sum += EarningsCalculator.totalEarning(trip);
    }
    return sum;
  }

  List<RideHistoryTrip> _buildVisibleTrips({
    required List<RideHistoryTrip> trips,
    required RideHistoryFilter filter,
    required RideHistorySort sort,
    required String query,
  }) {
    Iterable<RideHistoryTrip> next = trips;

    if (filter == RideHistoryFilter.completed) {
      next = next.where((RideHistoryTrip t) {
        return t.completedAtEpochMs != null && t.canceledAtEpochMs == null;
      });
    } else if (filter == RideHistoryFilter.canceled) {
      next = next.where((RideHistoryTrip t) => t.canceledAtEpochMs != null);
    } else if (filter == RideHistoryFilter.inProgress) {
      next = next.where((RideHistoryTrip t) {
        return t.completedAtEpochMs == null && t.canceledAtEpochMs == null;
      });
    }

    if (query.isNotEmpty) {
      next = next.where((RideHistoryTrip t) {
        return t.pickupLocation.toLowerCase().contains(query) ||
            t.dropLocation.toLowerCase().contains(query) ||
            t.id.toLowerCase().contains(query);
      });
    }

    final List<RideHistoryTrip> sorted = next.toList(growable: false);
    sorted.sort((RideHistoryTrip a, RideHistoryTrip b) {
      final int aKey = a.acceptedAtEpochMs;
      final int bKey = b.acceptedAtEpochMs;
      if (sort == RideHistorySort.latestFirst) return bKey.compareTo(aKey);
      return aKey.compareTo(bKey);
    });
    return sorted;
  }
}
