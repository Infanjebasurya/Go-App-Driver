import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/wallet_display.dart';
import 'package:goapp/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:goapp/features/earnings/domain/usecases/get_earnings_snapshot_usecase.dart';
import 'package:goapp/features/earnings/domain/usecases/get_wallet_transactions_usecase.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:goapp/features/earnings/presentation/pages/earnings_details_page.dart';
import 'package:goapp/features/earnings/presentation/pages/wallet_page.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const EarningsRepositoryImpl();
    return BlocProvider<EarningsCubit>(
      create: (_) => EarningsCubit(
        getEarningsSnapshot: GetEarningsSnapshotUseCase(repository),
        getWalletTransactions: GetWalletTransactionsUseCase(repository),
      )..load(),
      child: const _EarningsView(),
    );
  }
}

class _EarningsView extends StatefulWidget {
  const _EarningsView();

  @override
  State<_EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<_EarningsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceF5,
      appBar: AppAppBar(
        title: const Text('Earnings'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              dividerColor: AppColors.transparent,
              labelColor: AppColors.black,
              unselectedLabelColor: AppColors.neutral888,
              indicatorColor: AppColors.emerald,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const <Tab>[
                Tab(text: 'All Earnings'),
                Tab(text: 'Wallet'),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<EarningsCubit, EarningsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _AllEarningsView(state: state),
                    _WalletMenuView(state: state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AllEarningsView extends StatelessWidget {
  const _AllEarningsView({required this.state});

  final EarningsState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              final cubit = context.read<EarningsCubit>();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<EarningsCubit>.value(
                    value: cubit,
                    child: const EarningsDetailsPage(),
                  ),
                ),
              );
            },
            child: _SummaryCard(amount: state.snapshot.todaysEarnings),
          ),
          const SizedBox(height: 24),
          _MenuItem(
            icon: Icons.receipt_long,
            title: 'All Orders',
            subtitle: 'View history and daily breakdowns',
            onTap: () {
              final cubit = context.read<EarningsCubit>();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<EarningsCubit>.value(
                    value: cubit,
                    child: const EarningsDetailsPage(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _MenuItem(
            icon: Icons.payments,
            title: 'View Rate Card',
            subtitle: 'Standard rates and surge pricing',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _WalletMenuView extends StatelessWidget {
  const _WalletMenuView({required this.state});

  final EarningsState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              final cubit = context.read<EarningsCubit>();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<EarningsCubit>.value(
                    value: cubit,
                    child: const WalletPage(),
                  ),
                ),
              );
            },
            child: _SummaryCard(
              amount: walletDisplayBalance(state.snapshot.walletBalance),
            ),
          ),
          const SizedBox(height: 24),
          _MenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle: 'Recharge and withdraw balance',
            onTap: () {
              final cubit = context.read<EarningsCubit>();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<EarningsCubit>.value(
                    value: cubit,
                    child: const WalletPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.hex14000000,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Today\'s Earnings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral666,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(
                  text: '\u20B9',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral666,
                  ),
                ),
                TextSpan(
                  text: amount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 48,
                    fontFamily: "Saira",
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.trending_up, color: AppColors.emerald, size: 16),
                SizedBox(width: 4),
                Text(
                  '+12% vs yesterday',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.hex0D000000,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.earningsAccentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.emerald, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral666,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.neutral888,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





