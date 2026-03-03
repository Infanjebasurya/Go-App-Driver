import 'package:goapp/features/incentives/domain/entities/incentives_config.dart';
import 'package:goapp/features/incentives/domain/repositories/incentives_repository.dart';

class GetIncentivesConfigUseCase {
  const GetIncentivesConfigUseCase(this._repository);

  final IncentivesRepository _repository;

  Future<IncentivesConfig> call() {
    return _repository.getConfig();
  }
}
