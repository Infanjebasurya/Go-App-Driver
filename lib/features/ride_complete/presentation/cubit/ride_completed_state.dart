import 'package:equatable/equatable.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_completion_summary.dart';

class RideCompletedState extends Equatable {
  const RideCompletedState({required this.summary, this.isQrExpanded = false});

  final RideCompletionSummary summary;
  final bool isQrExpanded;

  RideCompletedState copyWith({
    RideCompletionSummary? summary,
    bool? isQrExpanded,
  }) {
    return RideCompletedState(
      summary: summary ?? this.summary,
      isQrExpanded: isQrExpanded ?? this.isQrExpanded,
    );
  }

  @override
  List<Object> get props => <Object>[summary, isQrExpanded];
}
