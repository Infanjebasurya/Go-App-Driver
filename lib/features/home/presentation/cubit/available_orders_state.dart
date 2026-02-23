import 'package:equatable/equatable.dart';

class AvailableOrdersState extends Equatable {
  const AvailableOrdersState({
    this.activeOrderIndex = 0,
    this.progress = 0,
    this.showSecondOrder = false,
  });

  final int activeOrderIndex;
  final double progress;
  final bool showSecondOrder;

  AvailableOrdersState copyWith({
    int? activeOrderIndex,
    double? progress,
    bool? showSecondOrder,
  }) {
    return AvailableOrdersState(
      activeOrderIndex: activeOrderIndex ?? this.activeOrderIndex,
      progress: progress ?? this.progress,
      showSecondOrder: showSecondOrder ?? this.showSecondOrder,
    );
  }

  @override
  List<Object> get props => <Object>[activeOrderIndex, progress, showSecondOrder];
}
