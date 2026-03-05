import 'package:equatable/equatable.dart';

class AvailableOrdersState extends Equatable {
  const AvailableOrdersState({
    this.activeOrderIndex = 0,
    this.progress = 0,
    this.showSecondOrder = false,
    this.showThirdOrder = false,
  });

  final int activeOrderIndex;
  final double progress;
  final bool showSecondOrder;
  final bool showThirdOrder;

  AvailableOrdersState copyWith({
    int? activeOrderIndex,
    double? progress,
    bool? showSecondOrder,
    bool? showThirdOrder,
  }) {
    return AvailableOrdersState(
      activeOrderIndex: activeOrderIndex ?? this.activeOrderIndex,
      progress: progress ?? this.progress,
      showSecondOrder: showSecondOrder ?? this.showSecondOrder,
      showThirdOrder: showThirdOrder ?? this.showThirdOrder,
    );
  }

  @override
  List<Object> get props => <Object>[
    activeOrderIndex,
    progress,
    showSecondOrder,
    showThirdOrder,
  ];
}
