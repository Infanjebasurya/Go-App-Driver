import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/earnings/domain/usecases/get_earnings_snapshot_usecase.dart';
import 'package:goapp/features/earnings/domain/usecases/get_wallet_transactions_usecase.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';

class EarningsCubit extends Cubit<EarningsState> {
  EarningsCubit({
    required GetEarningsSnapshotUseCase getEarningsSnapshot,
    required GetWalletTransactionsUseCase getWalletTransactions,
  }) : _getEarningsSnapshot = getEarningsSnapshot,
       _getWalletTransactions = getWalletTransactions,
       super(const EarningsState());

  final GetEarningsSnapshotUseCase _getEarningsSnapshot;
  final GetWalletTransactionsUseCase _getWalletTransactions;

  Future<void> load() async {
    final snapshot = await _getEarningsSnapshot();
    final transactions = await _getWalletTransactions();
    emit(
      state.copyWith(
        isLoading: false,
        snapshot: snapshot,
        transactions: transactions,
      ),
    );
  }

  void selectPeriod(EarningsPeriod period) {
    emit(state.copyWith(period: period));
  }

  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }

  void selectBank(String bank) {
    emit(state.copyWith(selectedBank: bank));
  }

  void setRechargeAmount(String amount) {
    emit(state.copyWith(rechargeAmount: amount));
  }

  void addRechargeAmount(int amount) {
    final current = int.tryParse(state.rechargeAmount.replaceAll(',', '')) ?? 0;
    emit(state.copyWith(rechargeAmount: (current + amount).toString()));
  }
}
