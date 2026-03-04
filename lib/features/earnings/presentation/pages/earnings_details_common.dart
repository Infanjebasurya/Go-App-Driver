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
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
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
                  style: TextStyle(color: AppColors.neutral666, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 36 / 1.3, fontWeight: FontWeight.bold),
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
                  style: TextStyle(color: AppColors.neutral666, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  rides.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 36 / 1.3, fontWeight: FontWeight.bold),
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
        tabs: const <Tab>[Tab(text: 'Completed'), Tab(text: 'Cancelled')],
      ),
    );
  }
}

class _CompletedList extends StatelessWidget {
  const _CompletedList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RideHistoryTrip>>(
      future: RideHistoryStore.loadTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<RideHistoryTrip> completed =
            (snapshot.data ?? const <RideHistoryTrip>[]).where(EarningsCalculator.isCompletedTrip).toList();
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
                trip.startedAtEpochMs ?? trip.pickedUpAtEpochMs ?? trip.acceptedAtEpochMs;
            final int endEpoch = trip.completedAtEpochMs ?? startEpoch;
            return TripCard(
              date: _formatDateLabel(endEpoch),
              timeRange: '${_formatTimeLabel(startEpoch)} to ${_formatTimeLabel(endEpoch)}',
              price: '₹${EarningsCalculator.totalEarning(trip).toStringAsFixed(2)}',
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

class _CancelledList extends StatelessWidget {
  const _CancelledList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RideHistoryTrip>>(
      future: RideHistoryStore.loadTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<RideHistoryTrip> canceled =
            (snapshot.data ?? const <RideHistoryTrip>[]).where(EarningsCalculator.isCanceledTrip).toList();
        if (canceled.isEmpty) {
          return const _OrderHistoryEmptyState(message: 'No cancelled orders');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: canceled.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final RideHistoryTrip trip = canceled[index];
            final int epoch = trip.canceledAtEpochMs ?? trip.acceptedAtEpochMs;
            return TripCard(
              date: _formatDateLabel(epoch),
              timeRange: _formatTimeLabel(epoch),
              price: '₹${EarningsCalculator.totalEarning(trip).toStringAsFixed(2)}',
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
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: accentColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
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
        style: const TextStyle(color: AppColors.neutral666, fontWeight: FontWeight.w600),
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
  const List<String> weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
