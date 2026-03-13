import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({super.key, required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final _WalletTxnVisual visual = _WalletTxnVisual.fromType(item.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: <Widget>[
            Container(width: 2.4, height: 98, color: visual.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.hexFFF8F8F8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(visual.icon, color: visual.accent, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (item.type == WalletTransactionType.recharge &&
                                  item.status != null) ...<Widget>[
                                const SizedBox(width: 8),
                                _RechargeStatusBadge(status: item.status!),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: AppColors.neutralAAA,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.amount,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RechargeStatusBadge extends StatelessWidget {
  const _RechargeStatusBadge({required this.status});

  final WalletTransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final ({Color bg, Color fg, String label}) style = switch (status) {
      WalletTransactionStatus.completed => (
        bg: AppColors.hexFFEAF8F1,
        fg: AppColors.hexFF0C9B61,
        label: 'Completed',
      ),
      WalletTransactionStatus.pending => (
        bg: AppColors.hexFFFFF8E1,
        fg: AppColors.hexFFB45309,
        label: 'Pending',
      ),
      WalletTransactionStatus.cancelled => (
        bg: AppColors.hexFFFFEEEE,
        fg: AppColors.hexFFE53935,
        label: 'Cancelled',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class WalletHistoryTabBar extends StatelessWidget {
  const WalletHistoryTabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      labelColor: AppColors.black,
      unselectedLabelColor: AppColors.neutral666,
      indicatorColor: AppColors.emerald,
      indicatorWeight: 2,
      dividerColor: AppColors.transparent,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      tabs: const <Tab>[
        Tab(text: 'All'),
        Tab(text: 'Earnings'),
        Tab(text: 'Recharge'),
        Tab(text: 'Withdrawals'),
      ],
    );
  }
}

class _WalletTxnVisual {
  const _WalletTxnVisual({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  factory _WalletTxnVisual.fromType(WalletTransactionType type) {
    return switch (type) {
      WalletTransactionType.earning => const _WalletTxnVisual(
        icon: Icons.account_balance_wallet_rounded,
        accent: AppColors.emerald,
      ),
      WalletTransactionType.recharge => const _WalletTxnVisual(
        icon: Icons.add_circle_outline,
        accent: AppColors.emerald,
      ),
      WalletTransactionType.withdrawal => const _WalletTxnVisual(
        icon: Icons.account_balance_outlined,
        accent: AppColors.validationRed,
      ),
    };
  }
}
