import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/earnings/domain/entities/transaction_item.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:goapp/features/earnings/presentation/widgets/wallet_common_widgets.dart';

class WalletTransactionsPage extends StatefulWidget {
  const WalletTransactionsPage({super.key});

  @override
  State<WalletTransactionsPage> createState() => _WalletTransactionsPageState();
}

class _WalletTransactionsPageState extends State<WalletTransactionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          final List<TransactionItem> all = state.transactions;
          final List<TransactionItem> earnings = all
              .where((item) => item.type == WalletTransactionType.earning)
              .toList(growable: false);
          final List<TransactionItem> walletOnly = all
              .where((item) => item.type != WalletTransactionType.earning)
              .toList(growable: false);
          final List<TransactionItem> recharges = walletOnly
              .where((item) => item.type == WalletTransactionType.recharge)
              .toList(growable: false);
          final List<TransactionItem> withdrawals = walletOnly
              .where((item) => item.type == WalletTransactionType.withdrawal)
              .toList(growable: false);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: WalletHistoryTabBar(controller: _tabController),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _WalletTransactionsList(items: all),
                    _WalletTransactionsList(items: earnings),
                    _WalletTransactionsList(items: recharges),
                    _WalletTransactionsList(items: withdrawals),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WalletTransactionsList extends StatelessWidget {
  const _WalletTransactionsList({required this.items});

  final List<TransactionItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No wallet transactions found',
          style: TextStyle(
            color: AppColors.neutral666,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final _DateBuckets buckets = _bucketByDate(items);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontal = constraints.maxWidth >= 700
            ? constraints.maxWidth * 0.14
            : 14;
        return ListView(
          padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 16),
          children: <Widget>[
            if (buckets.today.isNotEmpty) ...<Widget>[
              const _DateHeading(label: 'Today'),
              ...buckets.today.map((e) => WalletTransactionTile(item: e)),
            ],
            if (buckets.yesterday.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              const _DateHeading(label: 'Yesterday'),
              ...buckets.yesterday.map((e) => WalletTransactionTile(item: e)),
            ],
            if (buckets.older.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              const _DateHeading(label: 'Older'),
              ...buckets.older.map((e) => WalletTransactionTile(item: e)),
            ],
          ],
        );
      },
    );
  }
}

class _DateHeading extends StatelessWidget {
  const _DateHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 0, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral666,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DateBuckets {
  const _DateBuckets({
    required this.today,
    required this.yesterday,
    required this.older,
  });

  final List<TransactionItem> today;
  final List<TransactionItem> yesterday;
  final List<TransactionItem> older;
}

_DateBuckets _bucketByDate(List<TransactionItem> items) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime yesterday = today.subtract(const Duration(days: 1));

  final List<TransactionItem> todayItems = <TransactionItem>[];
  final List<TransactionItem> yesterdayItems = <TransactionItem>[];
  final List<TransactionItem> olderItems = <TransactionItem>[];

  for (final TransactionItem item in items) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(item.eventEpochMs);
    final DateTime day = DateTime(dt.year, dt.month, dt.day);
    if (day == today) {
      todayItems.add(item);
    } else if (day == yesterday) {
      yesterdayItems.add(item);
    } else {
      olderItems.add(item);
    }
  }

  return _DateBuckets(
    today: todayItems,
    yesterday: yesterdayItems,
    older: olderItems,
  );
}
