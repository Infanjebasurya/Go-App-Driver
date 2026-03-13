import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/utils/earnings_calculator.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:goapp/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:goapp/features/earnings/presentation/widgets/trip_card.dart';
import 'package:goapp/core/di/injection.dart';

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
      return BlocProvider<EarningsCubit>(
        create: (_) => sl<EarningsCubit>()..load(),
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
          appBar: AppAppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: const Text('Earnings'),
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

class _DayView extends StatefulWidget {
  const _DayView({required this.tabController, required this.state});

  final TabController tabController;
  final EarningsState state;

  @override
  State<_DayView> createState() => _DayViewState();
}

class _DayViewState extends State<_DayView> {
  late final DateTime _today;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selectedDay = _today;
  }

  List<DateTime> _daysToShow() {
    // Show the last 3 days ending at "today" style like the reference UI.
    return <DateTime>[
      _today.subtract(const Duration(days: 2)),
      _today.subtract(const Duration(days: 1)),
      _today,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 6),
        _DayDateChips(
          days: _daysToShow(),
          selectedDay: _selectedDay,
          onSelect: (day) => setState(() => _selectedDay = day),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<RideHistoryTrip>>(
          future: RideHistoryStore.loadTrips(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _RangeSummaryCard(
                total: widget.state.snapshot.totalEarned,
                rides: widget.state.snapshot.totalRides,
              );
            }
            final trips = snapshot.data ?? const <RideHistoryTrip>[];
            final completedForDay = trips
                .where((t) {
                  if (!EarningsCalculator.isCompletedTrip(t)) return false;
                  final epoch = t.completedAtEpochMs ?? 0;
                  return epoch > 0 &&
                      DateTime.fromMillisecondsSinceEpoch(epoch).year ==
                          _selectedDay.year &&
                      DateTime.fromMillisecondsSinceEpoch(epoch).month ==
                          _selectedDay.month &&
                      DateTime.fromMillisecondsSinceEpoch(epoch).day ==
                          _selectedDay.day;
                })
                .toList(growable: false);
            final total = completedForDay.fold<double>(
              0,
              (sum, t) => sum + EarningsCalculator.totalEarning(t),
            );
            return _RangeSummaryCard(
              total: total,
              rides: completedForDay.length,
            );
          },
        ),
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
        _OrderTabs(tabController: widget.tabController),
        const _TodaysActivityLabel(),
        Expanded(
          child: TabBarView(
            controller: widget.tabController,
            children: <Widget>[
              _CompletedList(day: _selectedDay),
              _CancelledList(day: _selectedDay),
            ],
          ),
        ),
      ],
    );
  }
}
