import 'package:equatable/equatable.dart';

enum WalletTransactionType { earning, recharge, withdrawal }

enum WalletTransactionStatus { completed, pending, cancelled }

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
    this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final double amountValue;
  final bool isCredit;
  final WalletTransactionType type;
  final int eventEpochMs;
  final WalletTransactionStatus? status;

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
    status ?? '',
  ];
}
