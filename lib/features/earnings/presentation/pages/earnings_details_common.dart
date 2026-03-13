part of 'earnings_details_page.dart';

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

class _RangeSummaryCard extends StatelessWidget {
  const _RangeSummaryCard({required this.total, required this.rides});

  final double total;
  final int rides;

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
            color: AppColors.hex14000000,
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
                  '\u20B9${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 36 / 1.3,
                    fontWeight: FontWeight.bold,
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
                  rides.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 36 / 1.3,
                    fontWeight: FontWeight.bold,
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
    return TabBar(
      controller: tabController,
      dividerColor: AppColors.transparent,
      labelColor: AppColors.black,
      unselectedLabelColor: AppColors.neutral888,
      indicatorColor: AppColors.emerald,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      tabs: const <Tab>[
        Tab(text: 'Completed'),
        Tab(text: 'Cancelled'),
      ],
    );
  }
}

class _DayDateChips extends StatelessWidget {
  const _DayDateChips({
    required this.days,
    required this.selectedDay,
    required this.onSelect,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = _isSameDay(day, selectedDay);
          return _DayDateChip(
            day: day,
            selected: selected,
            onTap: () => onSelect(day),
          );
        },
      ),
    );
  }
}

class _DayDateChip extends StatelessWidget {
  const _DayDateChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.emerald;
    final Color textColor = selected ? accent : AppColors.neutral666;
    final Color bg = selected
        ? accent.withValues(alpha: 0.12)
        : AppColors.white;
    final BorderSide? borderSide = selected
        ? BorderSide(color: accent, width: 1.2)
        : null;

    const List<String> weekdays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    final String label = weekdays[day.weekday - 1];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: borderSide == null ? null : Border.fromBorderSide(borderSide),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              day.day.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedList extends StatelessWidget {
  const _CompletedList({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RideHistoryTrip>>(
      future: RideHistoryStore.loadTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<RideHistoryTrip> completed =
            (snapshot.data ?? const <RideHistoryTrip>[])
                .where(EarningsCalculator.isCompletedTrip)
                .where((trip) {
                  final epoch = trip.completedAtEpochMs ?? 0;
                  return _isEpochInDay(epoch, day);
                })
                .toList();
        if (completed.isEmpty) {
          return const _OrderHistoryEmptyState(message: 'No completed orders');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: completed.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final RideHistoryTrip trip = completed[index];
            final int startEpoch =
                trip.startedAtEpochMs ??
                trip.pickedUpAtEpochMs ??
                trip.acceptedAtEpochMs;
            final int endEpoch = trip.completedAtEpochMs ?? startEpoch;
            return TripCard(
              date: _formatDateLabel(endEpoch),
              timeRange:
                  '${_formatTimeLabel(startEpoch)} to ${_formatTimeLabel(endEpoch)}',
              price:
                  '\u20B9${EarningsCalculator.totalEarning(trip).toStringAsFixed(2)}',
              pickupLocation: _locationTitle(trip.pickupLocation),
              pickupAddress: trip.pickupLocation,
              dropLocation: _locationTitle(trip.dropLocation),
              dropAddress: trip.dropLocation,
            );
          },
        );
      },
    );
  }
}

class _TodaysActivityLabel extends StatelessWidget {
  const _TodaysActivityLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Today's Activity",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral666,
          ),
        ),
      ),
    );
  }
}

class _CancelledList extends StatelessWidget {
  const _CancelledList({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RideHistoryTrip>>(
      future: RideHistoryStore.loadTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<RideHistoryTrip> cancelled =
            (snapshot.data ?? const <RideHistoryTrip>[])
                .where(EarningsCalculator.isCanceledTrip)
                .where((trip) {
                  final epoch = trip.canceledAtEpochMs ?? 0;
                  return _isEpochInDay(epoch, day);
                })
                .toList();
        if (cancelled.isEmpty) {
          return const _OrderHistoryEmptyState(message: 'No cancelled orders');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: cancelled.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final RideHistoryTrip trip = cancelled[index];
            final int startEpoch =
                trip.startedAtEpochMs ??
                trip.pickedUpAtEpochMs ??
                trip.acceptedAtEpochMs;
            final int endEpoch = trip.canceledAtEpochMs ?? startEpoch;
            return TripCard(
              date: _formatDateLabel(endEpoch),
              timeRange:
                  '${_formatTimeLabel(startEpoch)} to ${_formatTimeLabel(endEpoch)}',
              statusLine: 'Cancelled by Customer',
              price:
                  '\u20B9${EarningsCalculator.totalEarning(trip).toStringAsFixed(0)}',
              pickupLocation: _locationTitle(trip.pickupLocation),
              pickupAddress: trip.pickupLocation,
              dropLocation: _locationTitle(trip.dropLocation),
              dropAddress: trip.dropLocation,
              isCancelled: true,
            );
          },
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.accent,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String amount;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = accent ?? AppColors.emerald;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        constraints: const BoxConstraints(minHeight: 94),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: accentColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 32 / 2,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.neutral666,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 37 / 1.5,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.neutralCCC,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderHistoryEmptyState extends StatelessWidget {
  const _OrderHistoryEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.neutral666,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _locationTitle(String address) {
  final List<String> chunks = address.split(',');
  final String first = chunks.first.trim();
  if (first.isEmpty) return 'Unknown';
  return first;
}

String _formatDateLabel(int epochMs) {
  final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  const List<String> weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
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
  return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]}';
}

String _formatTimeLabel(int epochMs) {
  final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final int hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final String minute = dt.minute.toString().padLeft(2, '0');
  final String amPm = dt.hour >= 12 ? 'pm' : 'am';
  return '${hour12.toString().padLeft(2, '0')}:$minute$amPm';
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isEpochInDay(int epochMs, DateTime day) {
  if (epochMs <= 0) return false;
  final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return _isSameDay(dt, day);
}
