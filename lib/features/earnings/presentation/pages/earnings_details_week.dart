part of 'earnings_details_page.dart';

class _WeekView extends StatefulWidget {
  const _WeekView();

  @override
  State<_WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<_WeekView> with SingleTickerProviderStateMixin {
  int _rangeIndex = 1;
  late final TabController _orderTabController;

  @override
  void initState() {
    super.initState();
    _orderTabController = TabController(length: 2, vsync: this);
    _orderTabController.addListener(() {
      if (!mounted) return;
      if (_orderTabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _orderTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RideHistoryTrip>>(
      future: RideHistoryStore.loadTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<RideHistoryTrip> trips =
            snapshot.data ?? const <RideHistoryTrip>[];
        final List<_WeekRange> ranges = _buildWeekRanges();
        final _WeekRange selected =
            ranges[_rangeIndex.clamp(0, ranges.length - 1)];
        final bool showCancelled = _orderTabController.index == 1;
        final List<RideHistoryTrip> filtered = _filterTrips(
          trips: trips,
          range: selected,
          cancelled: showCancelled,
        );
        final double total = filtered.fold<double>(
          0,
          (sum, trip) => sum + EarningsCalculator.totalEarning(trip),
        );
        final int rides = filtered.length;
        final List<_DaySummary> daySummary = _buildDaySummary(
          filtered,
          cancelled: showCancelled,
        );
        final List<int> bars = _buildPerformanceBars(
          filtered,
          cancelled: showCancelled,
        );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              _WeekRangeChips(
                ranges: ranges,
                selectedIndex: _rangeIndex,
                onSelect: (index) => setState(() => _rangeIndex = index),
              ),
              const SizedBox(height: 16),
              _RangeSummaryCard(total: total, rides: rides),
              const SizedBox(height: 14),
              _PerformanceCard(values: bars),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Order History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              _OrderHistoryTabs(
                controller: _orderTabController,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Weekly Summary',
                  style: TextStyle(
                    color: AppColors.neutral666,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (daySummary.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Text(
                    'No rides in this period',
                    style: TextStyle(
                      color: AppColors.neutral666,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                ...daySummary.map((day) {
                  return _SummaryItem(
                    title: day.title,
                    subtitle: '${day.trips.length} Rides • Premium Class',
                    amount: '\u20B9${day.total.toStringAsFixed(2)}',
                    accent: showCancelled
                        ? AppColors.validationRed
                        : AppColors.emerald,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => _WeekDayDetailsPage(
                            dateTitle: day.title,
                            summaryPillText:
                                '\u20B9${day.total.toStringAsFixed(2)} • ${day.trips.length} Rides',
                            trips: day.trips,
                            showCancelled: showCancelled,
                          ),
                        ),
                      );
                    },
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _WeekDayDetailsPage extends StatelessWidget {
  const _WeekDayDetailsPage({
    required this.dateTitle,
    required this.summaryPillText,
    required this.trips,
    required this.showCancelled,
  });

  final String dateTitle;
  final String summaryPillText;
  final List<RideHistoryTrip> trips;
  final bool showCancelled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hexFFF7F7F7,
      appBar: AppAppBar(
        backgroundColor: AppColors.hexFFF7F7F7,
        elevation: 0,
        title: const Text('Week'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    dateTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: showCancelled
                        ? AppColors.rose
                        : AppColors.earningsAccentSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    summaryPillText,
                    style: TextStyle(
                      color: showCancelled
                          ? AppColors.validationRed
                          : AppColors.emerald,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final RideHistoryTrip trip = trips[index];
                final int startEpoch =
                    trip.startedAtEpochMs ??
                    trip.pickedUpAtEpochMs ??
                    trip.acceptedAtEpochMs;
                final int endEpoch = showCancelled
                    ? (trip.canceledAtEpochMs ?? startEpoch)
                    : (trip.completedAtEpochMs ?? startEpoch);
                return TripCard(
                  date: _formatDateLabel(endEpoch),
                  timeRange:
                      '${_formatTimeLabel(startEpoch)} to ${_formatTimeLabel(endEpoch)}',
                  price:
                      '\u20B9${EarningsCalculator.totalEarning(trip).toStringAsFixed(2)}',
                  statusLine: showCancelled
                      ? 'Canceled by ${_prettyCanceledBy(trip.canceledBy)}'
                      : null,
                  pickupLocation: _locationTitle(trip.pickupLocation),
                  pickupAddress: trip.pickupLocation,
                  dropLocation: _locationTitle(trip.dropLocation),
                  dropAddress: trip.dropLocation,
                  isCancelled: showCancelled,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _prettyCanceledBy(String? raw) {
  if (raw == null || raw.isEmpty) return 'Driver';
  final String lower = raw.toLowerCase();
  if (lower == 'customer') return 'Customer';
  return 'Driver';
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final int maxValue = values.fold<int>(1, (a, b) => a > b ? a : b);
    const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.hex10000000,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text(
                'Performance',
                style: TextStyle(
                  color: AppColors.neutral888,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              Spacer(),
              _LegendDot(label: 'Weekday', color: AppColors.emerald),
              SizedBox(width: 8),
              _LegendDot(label: 'Weekend', color: AppColors.gold),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List<Widget>.generate(values.length, (index) {
                final bool weekend = index == 5;
                final double h = ((values[index] / maxValue) * 85).clamp(
                  10,
                  85,
                );
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 4,
                      height: h,
                      decoration: BoxDecoration(
                        color: weekend ? AppColors.gold : AppColors.emerald,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        color: AppColors.neutralAAA,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
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
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

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
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _WeekRange {
  const _WeekRange({
    required this.start,
    required this.endExclusive,
    required this.label,
  });
  final DateTime start;
  final DateTime endExclusive;
  final String label;

  bool containsEpoch(int epochMs) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return !dt.isBefore(start) && dt.isBefore(endExclusive);
  }
}

class _DaySummary {
  const _DaySummary({
    required this.dayStart,
    required this.trips,
    required this.total,
    required this.title,
  });
  final DateTime dayStart;
  final List<RideHistoryTrip> trips;
  final double total;
  final String title;
}

List<_WeekRange> _buildWeekRanges() {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime currentWeekStart = today.subtract(
    Duration(days: today.weekday - DateTime.monday),
  );
  final DateTime previousWeekStart = currentWeekStart.subtract(
    const Duration(days: 7),
  );
  final DateTime currentWeekEnd = currentWeekStart.add(const Duration(days: 7));
  return <_WeekRange>[
    _WeekRange(
      start: previousWeekStart,
      endExclusive: currentWeekStart,
      label: _formatRangeLabel(
        previousWeekStart,
        currentWeekStart.subtract(const Duration(days: 1)),
      ),
    ),
    _WeekRange(
      start: currentWeekStart,
      endExclusive: currentWeekEnd,
      label: _formatRangeLabel(
        currentWeekStart,
        currentWeekEnd.subtract(const Duration(days: 1)),
      ),
    ),
  ];
}

String _formatRangeLabel(DateTime start, DateTime end) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[start.month - 1]} ${start.day.toString().padLeft(2, '0')} - ${end.day.toString().padLeft(2, '0')}';
}

List<RideHistoryTrip> _filterTrips({
  required List<RideHistoryTrip> trips,
  required _WeekRange range,
  required bool cancelled,
}) {
  return trips
      .where((trip) {
        final int epoch = cancelled
            ? (trip.canceledAtEpochMs ?? 0)
            : (trip.completedAtEpochMs ?? 0);
        if (epoch <= 0) return false;
        if (cancelled) {
          if (!EarningsCalculator.isCanceledTrip(trip)) return false;
        } else if (!EarningsCalculator.isCompletedTrip(trip)) {
          return false;
        }
        return range.containsEpoch(epoch);
      })
      .toList(growable: false);
}

List<int> _buildPerformanceBars(
  List<RideHistoryTrip> trips, {
  required bool cancelled,
}) {
  final List<int> counts = List<int>.filled(6, 0);
  for (final trip in trips) {
    final int epoch = cancelled
        ? (trip.canceledAtEpochMs ?? 0)
        : (trip.completedAtEpochMs ?? 0);
    if (epoch <= 0) continue;
    final int weekday = DateTime.fromMillisecondsSinceEpoch(epoch).weekday;
    if (weekday >= 1 && weekday <= 6) counts[weekday - 1] += 1;
  }
  return counts;
}

List<_DaySummary> _buildDaySummary(
  List<RideHistoryTrip> trips, {
  required bool cancelled,
}) {
  final Map<String, List<RideHistoryTrip>> grouped =
      <String, List<RideHistoryTrip>>{};
  for (final trip in trips) {
    final int epoch = cancelled
        ? (trip.canceledAtEpochMs ?? 0)
        : (trip.completedAtEpochMs ?? 0);
    if (epoch <= 0) continue;
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epoch);
    final DateTime day = DateTime(dt.year, dt.month, dt.day);
    grouped
        .putIfAbsent(
          '${day.year}-${day.month}-${day.day}',
          () => <RideHistoryTrip>[],
        )
        .add(trip);
  }
  final List<_DaySummary> result = grouped.values
      .map((list) {
        list.sort((a, b) {
          final int aEpoch = cancelled
              ? (a.canceledAtEpochMs ?? 0)
              : (a.completedAtEpochMs ?? 0);
          final int bEpoch = cancelled
              ? (b.canceledAtEpochMs ?? 0)
              : (b.completedAtEpochMs ?? 0);
          return bEpoch.compareTo(aEpoch);
        });
        final int epoch = cancelled
            ? (list.first.canceledAtEpochMs ?? 0)
            : (list.first.completedAtEpochMs ?? 0);
        final DateTime day = DateTime.fromMillisecondsSinceEpoch(epoch);
        final double total = list.fold<double>(
          0,
          (sum, t) => sum + EarningsCalculator.totalEarning(t),
        );
        return _DaySummary(
          dayStart: DateTime(day.year, day.month, day.day),
          trips: List<RideHistoryTrip>.from(list),
          total: total,
          title: _formatDateLabel(epoch),
        );
      })
      .toList(growable: false);
  result.sort((a, b) => b.dayStart.compareTo(a.dayStart));
  return result;
}
