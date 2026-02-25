import 'package:equatable/equatable.dart';
import 'package:goapp/features/earnings/domain/entities/earnings_snapshot.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';

enum EarningsPeriod { day, week, month }

class EarningsState extends Equatable {
  const EarningsState({
    this.isLoading = true,
    this.period = EarningsPeriod.day,
    this.selectedPaymentMethod = 'UPI Payments',
    this.selectedBank = 'SBI Bank',
    this.rechargeAmount = '2000',
    this.snapshot = const EarningsSnapshot(
      todaysEarnings: 0,
      totalEarned: 0,
      totalRides: 0,
      walletBalance: 0,
    ),
    this.transactions = const <TransactionItem>[],
  });

  final bool isLoading;
  final EarningsPeriod period;
  final String selectedPaymentMethod;
  final String selectedBank;
  final String rechargeAmount;
  final EarningsSnapshot snapshot;
  final List<TransactionItem> transactions;

  EarningsState copyWith({
    bool? isLoading,
    EarningsPeriod? period,
    String? selectedPaymentMethod,
    String? selectedBank,
    String? rechargeAmount,
    EarningsSnapshot? snapshot,
    List<TransactionItem>? transactions,
  }) {
    return EarningsState(
      isLoading: isLoading ?? this.isLoading,
      period: period ?? this.period,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedBank: selectedBank ?? this.selectedBank,
      rechargeAmount: rechargeAmount ?? this.rechargeAmount,
      snapshot: snapshot ?? this.snapshot,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object> get props => <Object>[
    isLoading,
    period,
    selectedPaymentMethod,
    selectedBank,
    rechargeAmount,
    snapshot,
    transactions,
  ];
}
