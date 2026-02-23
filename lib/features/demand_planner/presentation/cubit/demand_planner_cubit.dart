import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/peak_hour_model.dart';
import 'demand_planner_state.dart';

class DemandPlannerCubit extends Cubit<DemandPlannerState> {
  DemandPlannerCubit() : super(const DemandPlannerInitial()) {
    loadData();
  }

  static const _mockPeakHours = [
    PeakHour(
      timeRange: '04:30 PM - 6:00 PM',
      multiplier: 2.0,
      demandLevel: DemandLevel.high,
      isActive: true,
    ),
    PeakHour(
      timeRange: '06:00 PM - 7:30 PM',
      multiplier: 1.8,
      demandLevel: DemandLevel.moderate,
    ),
    PeakHour(
      timeRange: '7:30 PM - 9:00 PM',
      multiplier: 1.2,
      demandLevel: DemandLevel.steady,
    ),
  ];

  Future<void> loadData() async {
    emit(const DemandPlannerLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(
      const DemandPlannerLoaded(
        peakHours: _mockPeakHours,
        surgeNotificationsEnabled: true,
      ),
    );
  }

  void toggleSurgeNotifications() {
    if (state is! DemandPlannerLoaded) return;
    final current = state as DemandPlannerLoaded;
    emit(
      current.copyWith(
        surgeNotificationsEnabled: !current.surgeNotificationsEnabled,
      ),
    );
  }

  void toggleSheetExpanded() {
    if (state is! DemandPlannerLoaded) return;
    final current = state as DemandPlannerLoaded;
    emit(current.copyWith(isSheetExpanded: !current.isSheetExpanded));
  }

  void refresh() => loadData();
}
