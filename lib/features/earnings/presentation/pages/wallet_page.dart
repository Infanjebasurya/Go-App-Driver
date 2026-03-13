import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/wallet_display.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:goapp/features/earnings/presentation/pages/recharge_wallet_page.dart';
import 'package:goapp/features/earnings/presentation/pages/wallet_transactions_page.dart';
import 'package:goapp/features/earnings/presentation/pages/withdraw_page.dart';
import 'package:goapp/features/earnings/presentation/widgets/wallet_common_widgets.dart';
import 'package:goapp/core/di/injection.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    EarningsCubit? existingCubit;
    try {
      existingCubit = context.read<EarningsCubit>();
    } catch (_) {
      existingCubit = null;
    }
    if (existingCubit != null) {
      return BlocProvider<EarningsCubit>.value(
        value: existingCubit,
        child: const _WalletView(),
      );
    }

    return BlocProvider<EarningsCubit>(
      create: (_) => sl<EarningsCubit>()..load(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFF7F7F7,
      appBar: AppAppBar(
        backgroundColor: AppColors.hexFFF7F7F7,
        elevation: 0,
        centerTitle: true,
        title: const Text('Wallet'),
      ),
      body: BlocBuilder<EarningsCubit, EarningsState>(
        builder: (context, state) {
          final List<int> performanceBars = _buildWeekBars(state.transactions);
          final List<TransactionItem> walletTransactions = state.transactions
              .where((item) => item.type != WalletTransactionType.earning)
              .toList(growable: false);
          final List<TransactionItem> preview = walletTransactions
              .take(3)
              .toList(growable: false);
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool tablet = constraints.maxWidth >= 700;
              final double horizontal = tablet
                  ? constraints.maxWidth * 0.14
                  : 14;
              return ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 20),
                children: <Widget>[
                  _WalletBalanceCard(
                    balance: walletDisplayBalance(state.snapshot.walletBalance),
                    onRecharge: () {
                      final cubit = context.read<EarningsCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider<EarningsCubit>.value(
                            value: cubit,
                            child: const RechargeWalletPage(),
                          ),
                        ),
                      );
                    },
                    onWithdraw: () {
                      final cubit = context.read<EarningsCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider<EarningsCubit>.value(
                            value: cubit,
                            child: const WithdrawPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _WalletPerformanceCard(values: performanceBars),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 22 / 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral666,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final cubit = context.read<EarningsCubit>();
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider<EarningsCubit>.value(
                                value: cubit,
                                child: const WalletTransactionsPage(),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (preview.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          'No wallet history yet',
                          style: TextStyle(
                            color: AppColors.neutral666,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...preview.map((item) => WalletTransactionTile(item: item)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({
    required this.balance,
    required this.onRecharge,
    required this.onWithdraw,
  });

  final double balance;
  final VoidCallback onRecharge;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.hex14000000,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Available Balance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral666,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\u20B9${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 42 / 1.3,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: ShadowButton(
                  onPressed: onRecharge,
                  icon: const Icon(Icons.add_circle, size: 16),
                  label: const Text('Recharge Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShadowButton(
                  onPressed: onWithdraw,
                  icon: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16,
                  ),
                  label: const Text('Withdraw'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hexFFF3F3F3,
                    foregroundColor: AppColors.neutral666,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  shadowEnabled: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletPerformanceCard extends StatelessWidget {
  const _WalletPerformanceCard({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final int maxValue = values.fold<int>(1, (a, b) => a > b ? a : b);
    const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text(
                'Earning Performance',
                style: TextStyle(
                  color: AppColors.neutralAAA,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              Spacer(),
              _LegendDot(color: AppColors.emerald, label: 'Weekday'),
              SizedBox(width: 8),
              _LegendDot(color: AppColors.gold, label: 'Weekend'),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List<Widget>.generate(values.length, (index) {
                final bool weekend = index >= 5;
                final double height = ((values[index] / maxValue) * 86).clamp(
                  8,
                  86,
                );
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 4,
                      height: values[index] == 0 ? 0 : height,
                      decoration: BoxDecoration(
                        color: weekend ? AppColors.gold : AppColors.emerald,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        color: AppColors.neutralAAA,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.neutralAAA,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

List<int> _buildWeekBars(List<TransactionItem> transactions) {
  final List<int> counts = List<int>.filled(7, 0);
  for (final TransactionItem item in transactions) {
    if (item.type != WalletTransactionType.earning) continue;
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(item.eventEpochMs);
    final int weekday = dt.weekday;
    if (weekday >= 1 && weekday <= 7) counts[weekday - 1] += 1;
  }
  return counts;
}
