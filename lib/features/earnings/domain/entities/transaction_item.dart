import 'package:equatable/equatable.dart';

class TransactionItem extends Equatable {
  const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;

  @override
  List<Object> get props => <Object>[title, subtitle, amount, isCredit];
}
