import 'package:goapp/features/incentives/domain/entities/incentives_config.dart';

abstract interface class IncentivesRepository {
  Future<IncentivesConfig> getConfig();
}
