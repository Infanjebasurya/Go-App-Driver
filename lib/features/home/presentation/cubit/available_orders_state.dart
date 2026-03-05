import 'package:equatable/equatable.dart';

class AvailableOrdersState extends Equatable {
  const AvailableOrdersState({
    this.activeOrderIndex = 0,
    this.progress = 0,
    this.showSecondOrder = false,
    this.showThirdOrder = false,
    this.showFourthOrder = false,
  });

  final int activeOrderIndex;
  final double progress;
  final bool showSecondOrder;
  final bool showThirdOrder;
  final bool showFourthOrder;

  AvailableOrdersState copyWith({
    int? activeOrderIndex,
    double? progress,
    bool? showSecondOrder,
    bool? showThirdOrder,
    bool? showFourthOrder,
  }) {
    return AvailableOrdersState(
      activeOrderIndex: activeOrderIndex ?? this.activeOrderIndex,
      progress: progress ?? this.progress,
      showSecondOrder: showSecondOrder ?? this.showSecondOrder,
      showThirdOrder: showThirdOrder ?? this.showThirdOrder,
      showFourthOrder: showFourthOrder ?? this.showFourthOrder,
    );
  }

  @override
  List<Object> get props => <Object>[
    activeOrderIndex,
    progress,
    showSecondOrder,
    showThirdOrder,
    showFourthOrder,
  ];
}
