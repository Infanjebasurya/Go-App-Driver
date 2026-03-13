import 'package:goapp/features/earnings/data/datasources/earnings_wallet_mock_api.dart';
import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';
import 'package:goapp/features/earnings/domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  const EarningsRepositoryImpl({required EarningsWalletMockApi api})
    : _api = api;

  final EarningsWalletMockApi _api;

  @override
  Future<EarningsSnapshot> getSnapshot() async {
    return _api.fetchSnapshot();
  }

  @override
  Future<List<TransactionItem>> getTransactions() async {
    return _api.fetchTransactions();
  }
}
