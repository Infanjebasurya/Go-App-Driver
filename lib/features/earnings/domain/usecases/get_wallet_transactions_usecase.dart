import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';
import 'package:goapp/features/earnings/domain/repositories/earnings_repository.dart';

class GetWalletTransactionsUseCase {
  const GetWalletTransactionsUseCase(this._repository);

  final EarningsRepository _repository;

  Future<List<TransactionItem>> call() {
    return _repository.getTransactions();
  }
}
