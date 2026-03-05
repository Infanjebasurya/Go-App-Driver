class IncentiveTier {
  const IncentiveTier({
    required this.title,
    required this.targetRides,
    required this.rewardAmount,
  });

  final String title;
  final int targetRides;
  final int rewardAmount;
}

class IncentivesState {
  final String selectedTab;
  final int selectedDayIndex;
  final bool isLoading;
  final List<DateTime> dayOptions;
  final List<String> rangeLabels;
  final int achievedRides;
  final List<IncentiveTier> tiers;

  const IncentivesState({
    this.selectedTab = 'Day',
    this.selectedDayIndex = 0,
    this.isLoading = true,
    this.dayOptions = const <DateTime>[],
    this.rangeLabels = const <String>[],
    this.achievedRides = 0,
    this.tiers = const <IncentiveTier>[],
  });

  IncentivesState copyWith({
    String? selectedTab,
    int? selectedDayIndex,
    bool? isLoading,
    List<DateTime>? dayOptions,
    List<String>? rangeLabels,
    int? achievedRides,
    List<IncentiveTier>? tiers,
  }) {
    return IncentivesState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      isLoading: isLoading ?? this.isLoading,
      dayOptions: dayOptions ?? this.dayOptions,
      rangeLabels: rangeLabels ?? this.rangeLabels,
      achievedRides: achievedRides ?? this.achievedRides,
      tiers: tiers ?? this.tiers,
    );
  }
}
