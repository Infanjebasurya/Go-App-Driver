import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goapp/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:goapp/features/earnings/domain/usecases/get_earnings_snapshot_usecase.dart';
import 'package:goapp/features/earnings/domain/usecases/get_wallet_transactions_usecase.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';

void main() {
  group('EarningsCubit', () {
    late EarningsCubit cubit;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const repo = EarningsRepositoryImpl();
      cubit = EarningsCubit(
        getEarningsSnapshot: GetEarningsSnapshotUseCase(repo),
        getWalletTransactions: GetWalletTransactionsUseCase(repo),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('load fetches snapshot and transactions', () async {
      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.snapshot.todaysEarnings, greaterThanOrEqualTo(0));
      expect(cubit.state.snapshot.totalEarned, greaterThanOrEqualTo(0));
      expect(cubit.state.snapshot.totalRides, greaterThanOrEqualTo(0));
      expect(cubit.state.snapshot.walletBalance, greaterThanOrEqualTo(0));
    });

    test('period and payment selections update state', () {
      cubit.selectPeriod(EarningsPeriod.month);
      cubit.selectPaymentMethod('Net Banking');
      cubit.selectBank('HDFC Bank');
      cubit.setRechargeAmount('2500');
      cubit.addRechargeAmount(500);

      expect(cubit.state.period, EarningsPeriod.month);
      expect(cubit.state.selectedPaymentMethod, 'Net Banking');
      expect(cubit.state.selectedBank, 'HDFC Bank');
      expect(cubit.state.rechargeAmount, '3000');
    });
  });
}
