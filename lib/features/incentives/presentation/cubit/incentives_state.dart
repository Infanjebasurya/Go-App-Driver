class IncentivesState {
  final String selectedTab;
  final int selectedDayIndex;

  const IncentivesState({this.selectedTab = 'Day', this.selectedDayIndex = 2});

  IncentivesState copyWith({String? selectedTab, int? selectedDayIndex}) {
    return IncentivesState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
    );
  }
}
