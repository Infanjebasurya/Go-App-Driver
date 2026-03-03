import 'package:goapp/features/incentives/data/datasources/incentives_mock_api.dart';
import 'package:goapp/features/incentives/domain/entities/incentives_config.dart';
import 'package:goapp/features/incentives/domain/repositories/incentives_repository.dart';

class IncentivesRepositoryImpl implements IncentivesRepository {
  const IncentivesRepositoryImpl({IncentivesMockApi? api})
    : _api = api ?? const IncentivesMockApi();

  final IncentivesMockApi _api;

  @override
  Future<IncentivesConfig> getConfig() {
    return _api.fetchConfig();
  }
}
