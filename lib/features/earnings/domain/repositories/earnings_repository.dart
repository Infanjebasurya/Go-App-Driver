import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';

abstract interface class EarningsRepository {
  Future<EarningsSnapshot> getSnapshot();
  Future<List<TransactionItem>> getTransactions();
}
