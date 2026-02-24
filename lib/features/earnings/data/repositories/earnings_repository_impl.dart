import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';
import 'package:goapp/features/earnings/domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  const EarningsRepositoryImpl();

  @override
  Future<EarningsSnapshot> getSnapshot() async {
    return const EarningsSnapshot(
      todaysEarnings: 1450.50,
      totalEarned: 2450.0,
      totalRides: 3,
      walletBalance: 5430.50,
    );
  }

  @override
  Future<List<TransactionItem>> getTransactions() async {
    return const <TransactionItem>[
      TransactionItem(
        title: 'Trip Earning #8294',
        subtitle: 'Today, 2:45 PM',
        amount: '+₹850.00',
        isCredit: true,
      ),
      TransactionItem(
        title: 'Bank Transfer',
        subtitle: 'Today, 2:45 PM',
        amount: '-₹850.00',
        isCredit: false,
      ),
    ];
  }
}
