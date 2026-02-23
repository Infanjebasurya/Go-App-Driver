import 'package:equatable/equatable.dart';

class TripNavigationState extends Equatable {
  const TripNavigationState({
    this.progress = 0,
    this.showArrivalSheet = false,
  });

  final double progress;
  final bool showArrivalSheet;

  int get remainingMeters {
    final int meters = (400 * (1 - progress)).round();
    return meters < 0 ? 0 : meters;
  }

  TripNavigationState copyWith({
    double? progress,
    bool? showArrivalSheet,
  }) {
    return TripNavigationState(
      progress: progress ?? this.progress,
      showArrivalSheet: showArrivalSheet ?? this.showArrivalSheet,
    );
  }

  @override
  List<Object> get props => <Object>[progress, showArrivalSheet];
}
