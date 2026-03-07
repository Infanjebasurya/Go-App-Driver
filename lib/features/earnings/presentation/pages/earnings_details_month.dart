part of 'earnings_details_page.dart';

class _MonthView extends StatefulWidget {
  const _MonthView();

  @override
  State<_MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<_MonthView> {
  int _rangeIndex = 1;
  int _orderTab = 0; // 0 completed, 1 cancelled

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RideHistoryTrip>>(
      future: RideHistoryStore.loadTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<RideHistoryTrip> trips = snapshot.data ?? const <RideHistoryTrip>[];
        final List<_MonthRange> ranges = _buildMonthRanges();
        final _MonthRange selected = ranges[_rangeIndex.clamp(0, ranges.length - 1)];
        final bool showCancelled = _orderTab == 1;
        final List<RideHistoryTrip> filtered = _filterMonthTrips(
          trips: trips,
          range: selected,
          cancelled: showCancelled,
        );
        final double total = filtered.fold<double>(
          0,
          (sum, trip) => sum + EarningsCalculator.totalEarning(trip),
        );
        final List<int> bars = _buildMonthPerformanceBars(filtered);
        final List<_MonthWeekGroup> weeks = _buildMonthWeekGroups(filtered);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _MonthRangeChips(
                ranges: ranges,
                selectedIndex: _rangeIndex,
                onSelect: (index) => setState(() => _rangeIndex = index),
              ),
              const SizedBox(height: 4),
              _RangeSummaryCard(total: total, rides: filtered.length),
              const SizedBox(height: 14),
              _MonthPerformanceCard(values: bars),
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
                selectedIndex: _orderTab,
                onChanged: (index) => setState(() => _orderTab = index),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Monthly Summary',
                  style: TextStyle(color: AppColors.neutral666, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 6),
              if (weeks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Text(
                    showCancelled
                        ? 'No cancelled rides in this month'
                        : 'No completed rides in this month',
                    style: const TextStyle(color: AppColors.neutral666, fontWeight: FontWeight.w600),
                  ),
                )
              else
                ...weeks.map((week) {
                  final String rideLabel = showCancelled ? 'Cancelled Rides' : 'Completed Rides';
                  return _SummaryItem(
                    title: 'Week ${week.weekNo}',
                    subtitle: '${week.trips.length} $rideLabel',
                    amount: '\u20B9${week.total.toStringAsFixed(2)}',
                    accent: showCancelled ? AppColors.validationRed : AppColors.emerald,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => _MonthWeekDetailsPage(
                            weekTitle: 'Week ${week.weekNo}',
                            summaryPillText:
                                '\u20B9${week.total.toStringAsFixed(2)} \u2022 ${week.trips.length} Rides',
                            trips: week.trips,
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

class _MonthWeekDetailsPage extends StatelessWidget {
  const _MonthWeekDetailsPage({
    required this.weekTitle,
    required this.summaryPillText,
    required this.trips,
    required this.showCancelled,
  });

  final String weekTitle;
  final String summaryPillText;
  final List<RideHistoryTrip> trips;
  final bool showCancelled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppAppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Month',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                    weekTitle,
                    style: const TextStyle(fontSize: 30 / 1.6, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: showCancelled ? AppColors.rose : AppColors.earningsAccentSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        summaryPillText,
                        style: TextStyle(
                          color: showCancelled ? AppColors.validationRed : AppColors.emerald,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
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
                    trip.startedAtEpochMs ?? trip.pickedUpAtEpochMs ?? trip.acceptedAtEpochMs;
                final int endEpoch = showCancelled
                    ? (trip.canceledAtEpochMs ?? startEpoch)
                    : (trip.completedAtEpochMs ?? startEpoch);
                return TripCard(
                  date: _formatDateLabel(endEpoch),
                  timeRange: '${_formatTimeLabel(startEpoch)} to ${_formatTimeLabel(endEpoch)}',
                  price: '\u20B9${EarningsCalculator.totalEarning(trip).toStringAsFixed(2)}',
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

class _MonthPerformanceCard extends StatelessWidget {
  const _MonthPerformanceCard({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final int maxValue = values.fold<int>(1, (a, b) => a > b ? a : b);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text(
                'Performance',
                style: TextStyle(color: AppColors.neutral888, fontWeight: FontWeight.w700, fontSize: 12),
              ),
              Spacer(),
              _LegendDot(label: 'Monthly', color: AppColors.emerald),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 122,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List<Widget>.generate(5, (index) {
                final int count = values[index];
                final double height = ((count / maxValue) * 78).clamp(0, 78).toDouble();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 4,
                      height: height <= 0 ? 0 : (height < 12 ? 12 : height),
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Week ${index + 1}',
                      style: const TextStyle(
                        color: AppColors.neutral666,
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

class _MonthRangeChips extends StatelessWidget {
  const _MonthRangeChips({
    required this.ranges,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_MonthRange> ranges;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List<Widget>.generate(ranges.length, (index) {
          final bool selected = selectedIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: index == ranges.length - 1 ? 0 : 10),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFB7D7CC) : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(20),
                  border: selected ? Border.all(color: AppColors.emerald) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  ranges[index].label,
                  style: TextStyle(
                    color: selected ? AppColors.emerald : AppColors.neutral666,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MonthRange {
  const _MonthRange({required this.start, required this.endExclusive, required this.label});

  final DateTime start;
  final DateTime endExclusive;
  final String label;

  bool containsEpoch(int epochMs) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return !dt.isBefore(start) && dt.isBefore(endExclusive);
  }
}

class _MonthWeekGroup {
  const _MonthWeekGroup({
    required this.weekNo,
    required this.trips,
    required this.total,
  });

  final int weekNo;
  final List<RideHistoryTrip> trips;
  final double total;
}

List<_MonthRange> _buildMonthRanges() {
  final DateTime now = DateTime.now();
  final DateTime currentMonthStart = DateTime(now.year, now.month, 1);
  final DateTime nextMonthStart = DateTime(now.year, now.month + 1, 1);
  final DateTime previousMonthStart = DateTime(now.year, now.month - 1, 1);
  return <_MonthRange>[
    _MonthRange(
      start: previousMonthStart,
      endExclusive: currentMonthStart,
      label: _monthShortLabel(previousMonthStart),
    ),
    _MonthRange(
      start: currentMonthStart,
      endExclusive: nextMonthStart,
      label: _monthShortLabel(currentMonthStart),
    ),
  ];
}

String _monthShortLabel(DateTime date) {
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
  return months[date.month - 1];
}

List<RideHistoryTrip> _filterMonthTrips({
  required List<RideHistoryTrip> trips,
  required _MonthRange range,
  required bool cancelled,
}) {
  return trips.where((trip) {
    final int epoch = cancelled ? (trip.canceledAtEpochMs ?? 0) : (trip.completedAtEpochMs ?? 0);
    if (epoch <= 0) return false;
    if (cancelled) {
      if (!EarningsCalculator.isCanceledTrip(trip)) return false;
    } else if (!EarningsCalculator.isCompletedTrip(trip)) {
      return false;
    }
    return range.containsEpoch(epoch);
  }).toList(growable: false);
}

List<int> _buildMonthPerformanceBars(List<RideHistoryTrip> trips) {
  final List<int> counts = List<int>.filled(5, 0);
  for (final RideHistoryTrip trip in trips) {
    final int epoch = trip.completedAtEpochMs ?? trip.canceledAtEpochMs ?? 0;
    if (epoch <= 0) continue;
    final int day = DateTime.fromMillisecondsSinceEpoch(epoch).day;
    final int weekNo = ((day - 1) ~/ 7).clamp(0, 4);
    counts[weekNo] += 1;
  }
  return counts;
}

List<_MonthWeekGroup> _buildMonthWeekGroups(List<RideHistoryTrip> trips) {
  final Map<int, List<RideHistoryTrip>> grouped = <int, List<RideHistoryTrip>>{};
  for (final RideHistoryTrip trip in trips) {
    final int epoch = trip.completedAtEpochMs ?? trip.canceledAtEpochMs ?? 0;
    if (epoch <= 0) continue;
    final int weekNo = ((DateTime.fromMillisecondsSinceEpoch(epoch).day - 1) ~/ 7) + 1;
    grouped.putIfAbsent(weekNo, () => <RideHistoryTrip>[]).add(trip);
  }

  final List<int> keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
  return keys.map((weekNo) {
    final List<RideHistoryTrip> weekTrips = grouped[weekNo]!;
    weekTrips.sort((a, b) {
      final int aEpoch = a.completedAtEpochMs ?? a.canceledAtEpochMs ?? a.acceptedAtEpochMs;
      final int bEpoch = b.completedAtEpochMs ?? b.canceledAtEpochMs ?? b.acceptedAtEpochMs;
      return bEpoch.compareTo(aEpoch);
    });
    final double total = weekTrips.fold<double>(
      0,
      (sum, trip) => sum + EarningsCalculator.totalEarning(trip),
    );
    return _MonthWeekGroup(
      weekNo: weekNo,
      trips: List<RideHistoryTrip>.from(weekTrips),
      total: total,
    );
  }).toList(growable: false);
}

