import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/features/incentives/domain/usecases/get_incentives_config_usecase.dart';

import 'incentives_state.dart';

class IncentivesCubit extends Cubit<IncentivesState> {
  IncentivesCubit({required GetIncentivesConfigUseCase getIncentivesConfig})
    : _getIncentivesConfig = getIncentivesConfig,
      super(const IncentivesState()) {
    load();
  }

  final GetIncentivesConfigUseCase _getIncentivesConfig;

  Future<void> load() async {
    final config = await _getIncentivesConfig();
    final List<DateTime> dayOptions = _buildDayOptions();
    final String initialTab = config.defaultTab;
    final List<String> labels = _labelsForTab(initialTab, dayOptions);
    final int safeDefaultIndex = initialTab == 'Day'
        ? _todayIndex(dayOptions)
        : config.defaultDayIndex.clamp(0, labels.length - 1);
    emit(
      state.copyWith(
        selectedTab: initialTab,
        selectedDayIndex: safeDefaultIndex,
        dayOptions: dayOptions,
        rangeLabels: labels,
      ),
    );
    await _refreshProgress();
  }

  Future<void> selectTab(String tab) async {
    final List<String> labels = _labelsForTab(tab, state.dayOptions);
    int nextIndex = tab == 'Day'
        ? _todayIndex(state.dayOptions)
        : state.selectedDayIndex;
    if (nextIndex >= labels.length) nextIndex = labels.length - 1;
    if (nextIndex < 0) nextIndex = 0;
    emit(
      state.copyWith(
        selectedTab: tab,
        selectedDayIndex: nextIndex,
        rangeLabels: labels,
      ),
    );
    await _refreshProgress();
  }

  Future<void> selectDay(int dayIndex) async {
    emit(state.copyWith(selectedDayIndex: dayIndex));
    await _refreshProgress();
  }

  Future<void> _refreshProgress() async {
    emit(state.copyWith(isLoading: true));
    final List<RideHistoryTrip> trips = await RideHistoryStore.loadTrips();
    final List<RideHistoryTrip> completed = trips
        .where((trip) {
          return trip.completedAtEpochMs != null &&
              trip.canceledAtEpochMs == null;
        })
        .toList(growable: false);

    final int achieved = _achievedRidesForCurrentSelection(
      completedTrips: completed,
      selectedTab: state.selectedTab,
      dayOptions: state.dayOptions,
      selectedDayIndex: state.selectedDayIndex,
    );
    emit(
      state.copyWith(
        achievedRides: achieved,
        tiers: _tiersForTab(state.selectedTab),
        isLoading: false,
      ),
    );
  }

  List<DateTime> _buildDayOptions() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return List<DateTime>.generate(5, (index) {
      return today.subtract(Duration(days: 4 - index));
    });
  }

  int _achievedRidesForCurrentSelection({
    required List<RideHistoryTrip> completedTrips,
    required String selectedTab,
    required List<DateTime> dayOptions,
    required int selectedDayIndex,
  }) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    bool isWithin(DateTime ts, DateTime start, DateTime endExclusive) {
      return !ts.isBefore(start) && ts.isBefore(endExclusive);
    }

    if (selectedTab == 'Day') {
      if (dayOptions.isEmpty) return 0;
      final int safeIndex = selectedDayIndex.clamp(0, dayOptions.length - 1);
      final DateTime day = dayOptions[safeIndex];
      final DateTime start = DateTime(day.year, day.month, day.day);
      final DateTime end = start.add(const Duration(days: 1));
      return completedTrips.where((trip) {
        final int epoch = trip.completedAtEpochMs ?? 0;
        if (epoch <= 0) return false;
        return isWithin(DateTime.fromMillisecondsSinceEpoch(epoch), start, end);
      }).length;
    }

    if (selectedTab == 'Week') {
      final DateTime weekStart;
      final DateTime weekEnd;
      final int index = selectedDayIndex.clamp(0, 2);
      if (index == 0) {
        final DateTime currentWeekStart = today.subtract(
          Duration(days: today.weekday - DateTime.monday),
        );
        weekStart = currentWeekStart.subtract(const Duration(days: 14));
        weekEnd = weekStart.add(const Duration(days: 7));
      } else if (index == 1) {
        final DateTime currentWeekStart = today.subtract(
          Duration(days: today.weekday - DateTime.monday),
        );
        weekStart = currentWeekStart.subtract(const Duration(days: 7));
        weekEnd = currentWeekStart;
      } else {
        weekStart = today.subtract(
          Duration(days: today.weekday - DateTime.monday),
        );
        weekEnd = weekStart.add(const Duration(days: 7));
      }
      return completedTrips.where((trip) {
        final int epoch = trip.completedAtEpochMs ?? 0;
        if (epoch <= 0) return false;
        return isWithin(
          DateTime.fromMillisecondsSinceEpoch(epoch),
          weekStart,
          weekEnd,
        );
      }).length;
    }

    final int mIndex = selectedDayIndex.clamp(0, 2);
    final DateTime monthStart;
    final DateTime monthEnd;
    if (mIndex == 0) {
      monthStart = DateTime(now.year, now.month - 2, 1);
      monthEnd = DateTime(now.year, now.month - 1, 1);
    } else if (mIndex == 1) {
      monthStart = DateTime(now.year, now.month - 1, 1);
      monthEnd = DateTime(now.year, now.month, 1);
    } else {
      monthStart = DateTime(now.year, now.month, 1);
      monthEnd = DateTime(now.year, now.month + 1, 1);
    }
    return completedTrips.where((trip) {
      final int epoch = trip.completedAtEpochMs ?? 0;
      if (epoch <= 0) return false;
      return isWithin(
        DateTime.fromMillisecondsSinceEpoch(epoch),
        monthStart,
        monthEnd,
      );
    }).length;
  }

  List<IncentiveTier> _tiersForTab(String tab) {
    if (tab == 'Week') {
      return const <IncentiveTier>[
        IncentiveTier(
          title: 'Silver Milestone',
          targetRides: 25,
          rewardAmount: 600,
        ),
        IncentiveTier(
          title: 'Gold Milestone',
          targetRides: 50,
          rewardAmount: 600,
        ),
        IncentiveTier(
          title: 'Platinum Milestone',
          targetRides: 80,
          rewardAmount: 300,
        ),
      ];
    }
    if (tab == 'Bonus') {
      return const <IncentiveTier>[
        IncentiveTier(
          title: 'Silver Milestone',
          targetRides: 70,
          rewardAmount: 850,
        ),
        IncentiveTier(
          title: 'Gold Milestone',
          targetRides: 120,
          rewardAmount: 1400,
        ),
        IncentiveTier(
          title: 'Platinum Milestone',
          targetRides: 150,
          rewardAmount: 750,
        ),
      ];
    }
    return const <IncentiveTier>[
      IncentiveTier(
        title: 'Silver Milestone',
        targetRides: 3,
        rewardAmount: 50,
      ),
      IncentiveTier(title: 'Gold Milestone', targetRides: 5, rewardAmount: 100),
      IncentiveTier(
        title: 'Platinum Milestone',
        targetRides: 7,
        rewardAmount: 150,
      ),
    ];
  }

  List<String> _labelsForTab(String tab, List<DateTime> dayOptions) {
    if (tab == 'Day') {
      if (dayOptions.isEmpty) return const <String>[];
      return dayOptions
          .map((day) {
            const List<String> weekDays = <String>[
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
              'Sun',
            ];
            return weekDays[day.weekday - 1];
          })
          .toList(growable: false);
    }

    final DateTime now = DateTime.now();
    if (tab == 'Week') {
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime currentWeekStart = today.subtract(
        Duration(days: today.weekday - DateTime.monday),
      );
      final DateTime previousWeekStart = currentWeekStart.subtract(
        const Duration(days: 7),
      );
      final DateTime previousToPreviousWeekStart = currentWeekStart.subtract(
        const Duration(days: 14),
      );

      return <String>[
        _weekRangeLabel(
          previousToPreviousWeekStart,
          previousToPreviousWeekStart.add(const Duration(days: 6)),
        ),
        _weekRangeLabel(
          previousWeekStart,
          previousWeekStart.add(const Duration(days: 6)),
        ),
        _weekRangeLabel(
          currentWeekStart,
          currentWeekStart.add(const Duration(days: 6)),
        ),
      ];
    }

    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return <String>[
      months[DateTime(now.year, now.month - 2, 1).month - 1],
      months[DateTime(now.year, now.month - 1, 1).month - 1],
      months[DateTime(now.year, now.month, 1).month - 1],
    ];
  }

  String _weekRangeLabel(DateTime start, DateTime end) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[start.month - 1]} ${start.day.toString().padLeft(2, '0')} - ${end.day.toString().padLeft(2, '0')}';
  }

  int _todayIndex(List<DateTime> dayOptions) {
    if (dayOptions.isEmpty) return 0;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < dayOptions.length; i++) {
      final DateTime d = dayOptions[i];
      final DateTime n = DateTime(d.year, d.month, d.day);
      if (n == today) return i;
    }
    return dayOptions.length - 1;
  }
}
