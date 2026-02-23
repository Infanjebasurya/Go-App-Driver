enum DemandLevel { high, moderate, steady }

class PeakHour {
  final String timeRange;
  final double multiplier;
  final DemandLevel demandLevel;
  final bool isActive;

  const PeakHour({
    required this.timeRange,
    required this.multiplier,
    required this.demandLevel,
    this.isActive = false,
  });

  String get demandLabel {
    switch (demandLevel) {
      case DemandLevel.high:
        return 'High Demand';
      case DemandLevel.moderate:
        return 'Moderate Surge';
      case DemandLevel.steady:
        return 'Steady Trend';
    }
  }
}
