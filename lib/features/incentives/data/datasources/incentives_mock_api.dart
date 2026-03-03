import 'package:goapp/features/incentives/domain/entities/incentives_config.dart';

class IncentivesMockApi {
  const IncentivesMockApi();

  Future<IncentivesConfig> fetchConfig() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const IncentivesConfig(defaultTab: 'Day', defaultDayIndex: 2);
  }
}
