part of 'ride_history_screen.dart';

class _RideHistoryCard extends StatelessWidget {
  const _RideHistoryCard({
    required this.trip,
    required this.expanded,
    required this.onToggleExpand,
  });

  final RideHistoryTrip trip;
  final bool expanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final bool isCanceled = trip.canceledAtEpochMs != null;
    final bool isCompleted = trip.completedAtEpochMs != null && !isCanceled;

    return InkWell(
      onTap: onToggleExpand,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.strokeLight),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceFDF8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    size: 18,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trip ${trip.id.replaceFirst('trip_', '#')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral333,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  isCompleted: isCompleted,
                  isCanceled: isCanceled,
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.neutral666,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _LocationLine(
              icon: Icons.trip_origin_rounded,
              iconColor: AppColors.emerald,
              label: 'Pickup',
              value: trip.pickupLocation,
              showConnector: true,
            ),
            _LocationLine(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.validationRed,
              label: 'Drop',
              value: trip.dropLocation,
              showConnector: false,
            ),
            if (isCanceled) ...<Widget>[
              const SizedBox(height: 2),
              _InfoRow(
                label: 'Canceled By',
                value: _prettyCanceledBy(trip.canceledBy),
              ),
              _InfoRow(
                label: 'Cancel Reason',
                value: (trip.cancelReason == null || trip.cancelReason!.isEmpty)
                    ? 'Not provided'
                    : trip.cancelReason!,
              ),
            ],
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(height: 0),
              secondChild: Column(
                children: <Widget>[
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: AppColors.strokeLight),
                  const SizedBox(height: 10),
                  _InfoRow(
                    label: 'Accepted Time',
                    value: _formatEpoch(trip.acceptedAtEpochMs),
                  ),
                  _InfoRow(
                    label: 'Picked Up Time',
                    value: _formatNullableEpoch(trip.pickedUpAtEpochMs),
                  ),
                  _InfoRow(
                    label: 'Started Ride Time',
                    value: _formatNullableEpoch(trip.startedAtEpochMs),
                  ),
                  _InfoRow(
                    label: 'Completed Time',
                    value: _formatNullableEpoch(trip.completedAtEpochMs),
                  ),
                  if (trip.canceledAtEpochMs != null)
                    _InfoRow(
                      label: 'Canceled Time',
                      value: _formatNullableEpoch(trip.canceledAtEpochMs),
                    ),
                  if (trip.canceledBy != null && trip.canceledBy!.isNotEmpty)
                    _InfoRow(
                      label: 'Canceled By',
                      value: _prettyCanceledBy(trip.canceledBy),
                    ),
                  if (trip.cancelReason != null && trip.cancelReason!.isNotEmpty)
                    _InfoRow(
                      label: 'Cancel Reason',
                      value: trip.cancelReason!,
                    ),
                  if (trip.distanceLabel != null && trip.distanceLabel!.isNotEmpty)
                    _InfoRow(label: 'Distance', value: trip.distanceLabel!),
                  if (trip.fareLabel != null && trip.fareLabel!.isNotEmpty)
                    _InfoRow(label: 'Total Earnings', value: trip.fareLabel!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatNullableEpoch(int? epochMs) {
    if (epochMs == null || epochMs <= 0) return 'Not recorded';
    return _formatEpoch(epochMs);
  }

  static String _formatEpoch(int epochMs) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final String month = _month(dt.month);
    final String day = dt.day.toString().padLeft(2, '0');
    final int hour24 = dt.hour;
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String amPm = hour24 >= 12 ? 'PM' : 'AM';
    return '$day $month ${dt.year}, $hour12:$minute $amPm';
  }

  static String _month(int month) {
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
    return months[month - 1];
  }

  static String _prettyCanceledBy(String? raw) {
    if (raw == null || raw.isEmpty) return 'Unknown';
    final String lower = raw.toLowerCase();
    if (lower == 'driver') return 'Driver';
    if (lower == 'customer') return 'Customer';
    return raw;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isCompleted, this.isCanceled = false});

  final bool isCompleted;
  final bool isCanceled;

  @override
  Widget build(BuildContext context) {
    final Color bg = isCanceled
        ? AppColors.rose
        : (isCompleted ? AppColors.surfaceFDF8 : AppColors.warningSoft);
    final Color text = isCanceled
        ? AppColors.validationRed
        : (isCompleted ? AppColors.emerald : AppColors.warningText);
    final String label = isCanceled
        ? 'Canceled'
        : (isCompleted ? 'Completed' : 'In Progress');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.showConnector,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
            child: Column(
              children: <Widget>[
                Icon(icon, size: 16, color: iconColor),
                if (showConnector)
                  Container(
                    width: 1.2,
                    height: 26,
                    margin: const EdgeInsets.only(top: 3),
                    color: AppColors.neutralCCC,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral666,
                    ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral333,
                    height: 1.3,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral666,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral333,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



