import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/earnings_calculator.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:goapp/features/earnings/domain/usecases/get_earnings_snapshot_usecase.dart';
import 'package:goapp/features/earnings/domain/usecases/get_wallet_transactions_usecase.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:goapp/features/earnings/presentation/widgets/trip_card.dart';

part 'earnings_details_common.dart';
part 'earnings_details_month.dart';
part 'earnings_details_week.dart';
part 'earnings_details_week_helpers.dart';

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
          backgroundColor: const Color(0xFFF7F7F7),
          appBar: AppAppBar(
            backgroundColor: const Color(0xFFF7F7F7),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Earnings',
              style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceF5,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: <Widget>[
                    _PeriodTab(
                      label: 'Day',
                      selected: state.period == EarningsPeriod.day,
                      onTap: () => context.read<EarningsCubit>().selectPeriod(EarningsPeriod.day),
                    ),
                    _PeriodTab(
                      label: 'Week',
                      selected: state.period == EarningsPeriod.week,
                      onTap: () => context.read<EarningsCubit>().selectPeriod(EarningsPeriod.week),
                    ),
                    _PeriodTab(
                      label: 'Month',
                      selected: state.period == EarningsPeriod.month,
                      onTap: () => context.read<EarningsCubit>().selectPeriod(EarningsPeriod.month),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (state.period) {
                  EarningsPeriod.day => _DayView(tabController: tabController, state: state),
                  EarningsPeriod.week => const _WeekView(),
                  EarningsPeriod.month => const _MonthView(),
                },
              ),
            ],
          ),
        );
      },
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
        _RangeSummaryCard(total: state.snapshot.totalEarned, rides: state.snapshot.totalRides),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Order History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),
        _OrderTabs(tabController: tabController),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const <Widget>[
              _CompletedList(),
              _CancelledList(),
            ],
          ),
        ),
      ],
    );
  }
}
