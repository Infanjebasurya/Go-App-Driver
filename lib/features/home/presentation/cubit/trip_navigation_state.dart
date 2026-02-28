import 'package:equatable/equatable.dart';

class TripNavigationState extends Equatable {
  const TripNavigationState({
    this.progress = 0,
    this.showArrivalSheet = false,
    this.isPaused = false,
  });

  final double progress;
  final bool showArrivalSheet;
  final bool isPaused;

  int get remainingMeters {
    final int meters = (400 * (1 - progress)).round();
    return meters < 0 ? 0 : meters;
  }

  TripNavigationState copyWith({
    double? progress,
    bool? showArrivalSheet,
    bool? isPaused,
  }) {
    return TripNavigationState(
      progress: progress ?? this.progress,
      showArrivalSheet: showArrivalSheet ?? this.showArrivalSheet,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  List<Object> get props => <Object>[progress, showArrivalSheet, isPaused];
}
