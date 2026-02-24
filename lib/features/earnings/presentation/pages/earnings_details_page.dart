import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:goapp/features/earnings/domain/usecases/get_earnings_snapshot_usecase.dart';
import 'package:goapp/features/earnings/domain/usecases/get_wallet_transactions_usecase.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:goapp/features/earnings/presentation/pages/summary_details_page.dart';
import 'package:goapp/features/earnings/presentation/widgets/trip_card.dart';

class EarningsDetailsPage extends StatefulWidget {
  const EarningsDetailsPage({super.key});

  @override
  State<EarningsDetailsPage> createState() => _EarningsDetailsPageState();
}

class _EarningsDetailsPageState extends State<EarningsDetailsPage>
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
    EarningsCubit? existingCubit;
    try {
      existingCubit = context.read<EarningsCubit>();
    } catch (_) {
      existingCubit = null;
    }

    if (existingCubit == null) {
      final repository = const EarningsRepositoryImpl();
      return BlocProvider<EarningsCubit>(
        create: (_) => EarningsCubit(
          getEarningsSnapshot: GetEarningsSnapshotUseCase(repository),
          getWalletTransactions: GetWalletTransactionsUseCase(repository),
        )..load(),
        child: _EarningsDetailsBody(tabController: _tabController),
      );
    }

    return _EarningsDetailsBody(tabController: _tabController);
  }
}

class _EarningsDetailsBody extends StatelessWidget {
  const _EarningsDetailsBody({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EarningsCubit, EarningsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Earnings',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceF5,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: <Widget>[
                    _PeriodTab(
                      label: 'Day',
                      selected: state.period == EarningsPeriod.day,
                      onTap: () => context.read<EarningsCubit>().selectPeriod(
                        EarningsPeriod.day,
                      ),
                    ),
                    _PeriodTab(
                      label: 'Week',
                      selected: state.period == EarningsPeriod.week,
                      onTap: () => context.read<EarningsCubit>().selectPeriod(
                        EarningsPeriod.week,
                      ),
                    ),
                    _PeriodTab(
                      label: 'Month',
                      selected: state.period == EarningsPeriod.month,
                      onTap: () => context.read<EarningsCubit>().selectPeriod(
                        EarningsPeriod.month,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (state.period) {
                  EarningsPeriod.day => _DayView(
                    tabController: tabController,
                    state: state,
                  ),
                  EarningsPeriod.week => _WeekView(
                    tabController: tabController,
                    state: state,
                  ),
                  EarningsPeriod.month => _MonthView(
                    tabController: tabController,
                    state: state,
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: selected
              ? BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(25),
                )
              : null,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.neutral666,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({required this.tabController, required this.state});

  final TabController tabController;
  final EarningsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 10),
        _SummaryCard(state: state),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Order History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _OrderTabs(tabController: tabController),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: <Widget>[
              _CompletedList(state: state),
              _CancelledList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.tabController, required this.state});

  final TabController tabController;
  final EarningsState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10),
          _SummaryCard(state: state),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Weekly Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral666,
              ),
            ),
          ),
          _SummaryItem(
            title: 'Friday, 12 Feb',
            subtitle: '4 Rides • Premium Class',
            amount: '₹2,450',
          ),
          _SummaryItem(
            title: 'Thursday, 11 Feb',
            subtitle: '4 Rides • Premium Class',
            amount: '₹2,450',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({required this.tabController, required this.state});

  final TabController tabController;
  final EarningsState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10),
          _SummaryCard(state: state),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Monthly Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral666,
              ),
            ),
          ),
          _SummaryItem(
            title: 'Week 2',
            subtitle: '28 Completed Rides',
            amount: '₹5,450',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SummaryDetailsPage(
                    title: 'Month',
                    dateTitle: 'Week 2',
                    summaryPillText: '₹5,450 • 28 Rides',
                  ),
                ),
              );
            },
          ),
          _SummaryItem(
            title: 'Week 1',
            subtitle: '28 Completed Rides',
            amount: '₹4,450',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final EarningsState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Total Earned',
                  style: TextStyle(
                    color: AppColors.neutral666,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${state.snapshot.totalEarned.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.neutralCCC),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const Text(
                  'Rides',
                  style: TextStyle(
                    color: AppColors.neutral666,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.snapshot.totalRides.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
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

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.strokeLight)),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.black,
        unselectedLabelColor: AppColors.neutral888,
        indicatorColor: AppColors.emerald,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const <Tab>[
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }
}

class _CompletedList extends StatelessWidget {
  const _CompletedList({required this.state});

  final EarningsState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const <Widget>[
        TripCard(
          date: 'Today',
          timeRange: '05:30pm to 06:10pm',
          price: '₹850',
          pickupLocation: 'Arumbakkam',
          pickupAddress: '42 i-block, arumbakkam',
          dropLocation: 'VR Mall',
          dropAddress: '42 i-block, arumbakkam',
        ),
        SizedBox(height: 16),
        TripCard(
          date: 'Today',
          timeRange: '06:30pm to 07:00pm',
          price: '₹780',
          pickupLocation: 'Anna Nagar',
          pickupAddress: '12th Main Road',
          dropLocation: 'Express Avenue',
          dropAddress: 'Whites Road, Chennai',
        ),
      ],
    );
  }
}

class _CancelledList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const <Widget>[
        TripCard(
          date: 'Today',
          timeRange: '06:30pm',
          price: '₹0',
          pickupLocation: 'Anna Nagar',
          pickupAddress: '12th Main Road, Anna Nagar',
          dropLocation: 'VR Mall',
          dropAddress: '100ft Road, Anna Nagar',
          isCancelled: true,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.strokeLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.neutral666),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.neutral888),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
