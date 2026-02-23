import 'package:equatable/equatable.dart';

import '../model/peak_hour_model.dart';

abstract class DemandPlannerState extends Equatable {
  const DemandPlannerState();

  @override
  List<Object?> get props => [];
}

class DemandPlannerInitial extends DemandPlannerState {
  const DemandPlannerInitial();
}

class DemandPlannerLoading extends DemandPlannerState {
  const DemandPlannerLoading();
}

class DemandPlannerLoaded extends DemandPlannerState {
  final List<PeakHour> peakHours;
  final bool surgeNotificationsEnabled;
  final bool isSheetExpanded;

  const DemandPlannerLoaded({
    required this.peakHours,
    required this.surgeNotificationsEnabled,
    this.isSheetExpanded = false,
  });

  DemandPlannerLoaded copyWith({
    List<PeakHour>? peakHours,
    bool? surgeNotificationsEnabled,
    bool? isSheetExpanded,
  }) {
    return DemandPlannerLoaded(
      peakHours: peakHours ?? this.peakHours,
      surgeNotificationsEnabled:
          surgeNotificationsEnabled ?? this.surgeNotificationsEnabled,
      isSheetExpanded: isSheetExpanded ?? this.isSheetExpanded,
    );
  }

  @override
  List<Object?> get props => [
    peakHours,
    surgeNotificationsEnabled,
    isSheetExpanded,
  ];
}
