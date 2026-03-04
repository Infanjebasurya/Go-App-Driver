import 'package:equatable/equatable.dart';

enum WalletTransactionType { earning, recharge, withdrawal }

class TransactionItem extends Equatable {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountValue,
    required this.isCredit,
    required this.type,
    required this.eventEpochMs,
  });

  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final double amountValue;
  final bool isCredit;
  final WalletTransactionType type;
  final int eventEpochMs;

  @override
  List<Object> get props => <Object>[
    id,
    title,
    subtitle,
    amount,
    amountValue,
    isCredit,
    type,
    eventEpochMs,
  ];
}
