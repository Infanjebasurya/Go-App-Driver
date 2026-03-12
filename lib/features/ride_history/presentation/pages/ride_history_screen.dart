import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/ride_history/presentation/cubit/ride_history_cubit.dart';
import 'package:goapp/features/ride_history/presentation/cubit/ride_history_state.dart';
import 'package:goapp/core/di/injection.dart';

part 'ride_history_screen_header.dart';
part 'ride_history_screen_trip_card.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final RideHistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<RideHistoryCubit>();
    _cubit.loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RideHistoryCubit>.value(
      value: _cubit,
      child: BlocBuilder<RideHistoryCubit, RideHistoryState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surfaceF5,
            appBar: AppAppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text('Ride History'),
              actions: <Widget>[
                PopupMenuButton<RideHistorySort>(
                  icon: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.neutral555,
                  ),
                  initialValue: state.sort,
                  onSelected: _cubit.setSort,
                  itemBuilder: (_) => const <PopupMenuEntry<RideHistorySort>>[
                    PopupMenuItem<RideHistorySort>(
                      value: RideHistorySort.latestFirst,
                      child: Text('Latest First'),
                    ),
                    PopupMenuItem<RideHistorySort>(
                      value: RideHistorySort.oldestFirst,
                      child: Text('Oldest First'),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: AppColors.strokeLight, height: 1),
              ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _cubit.loadHistory,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      children: <Widget>[
                        _SummaryPanel(
                          totalTrips: state.allTrips.length,
                          completedTrips: _cubit.completedCount(),
                          canceledTrips: _cubit.canceledCount(),
                          earnings: _cubit.totalEarnings(),
                        ),
                        const SizedBox(height: 12),
                        _SearchField(
                          controller: _searchController,
                          onChanged: _cubit.setSearchQuery,
                        ),
                        const SizedBox(height: 10),
                        _FilterChips(
                          selected: state.filter,
                          totalCount: state.allTrips.length,
                          completedCount: _cubit.completedCount(),
                          inProgressCount: _cubit.inProgressCount(),
                          canceledCount: _cubit.canceledCount(),
                          onSelected: _cubit.setFilter,
                        ),
                        const SizedBox(height: 12),
                        if (state.visibleTrips.isEmpty) const _EmptyResultState(),
                        ...state.visibleTrips.map(
                          (RideHistoryTrip trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RideHistoryCard(
                              trip: trip,
                              expanded: state.expandedTripIds.contains(trip.id),
                              onToggleExpand: () => _cubit.toggleExpanded(trip.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}



