import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/repositories/earnings_repository.dart';

class GetEarningsSnapshotUseCase {
  const GetEarningsSnapshotUseCase(this._repository);

  final EarningsRepository _repository;

  Future<EarningsSnapshot> call() {
    return _repository.getSnapshot();
  }
}
