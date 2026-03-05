import 'package:goapp/features/demand_planner/presentation/model/peak_hour_model.dart';

class DemandPlannerMockApi {
  const DemandPlannerMockApi();

  Future<DemandPlannerPayload> fetchPlannerData() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const DemandPlannerPayload(
      peakHours: <PeakHour>[
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
      ],
      surgeNotificationsEnabled: true,
    );
  }
}

class DemandPlannerPayload {
  const DemandPlannerPayload({
    required this.peakHours,
    required this.surgeNotificationsEnabled,
  });

  final List<PeakHour> peakHours;
  final bool surgeNotificationsEnabled;
}
