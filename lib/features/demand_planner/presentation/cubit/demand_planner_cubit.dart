import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/demand_planner/data/datasources/demand_planner_mock_api.dart';

import 'demand_planner_state.dart';

class DemandPlannerCubit extends Cubit<DemandPlannerState> {
  DemandPlannerCubit({required DemandPlannerMockApi mockApi})
    : _mockApi = mockApi,
      super(const DemandPlannerInitial()) {
    loadData();
  }

  final DemandPlannerMockApi _mockApi;

  Future<void> loadData() async {
    emit(const DemandPlannerLoading());
    final DemandPlannerPayload payload = await _mockApi.fetchPlannerData();
    emit(
      DemandPlannerLoaded(
        peakHours: payload.peakHours,
        surgeNotificationsEnabled: payload.surgeNotificationsEnabled,
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
