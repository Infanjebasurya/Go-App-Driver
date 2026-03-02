part of 'ride_arrived_page.dart';

class _RouteDistanceMeta {
  const _RouteDistanceMeta({
    required this.cumulativeMeters,
    required this.totalMeters,
  });

  final List<double> cumulativeMeters;
  final double totalMeters;
}

class _CancellationReasonSheet extends StatefulWidget {
  const _CancellationReasonSheet({required this.onConfirm});

  final Future<void> Function(String canceledBy, String reason) onConfirm;

  @override
  State<_CancellationReasonSheet> createState() =>
      _CancellationReasonSheetState();
}

class _CancellationReasonSheetState extends State<_CancellationReasonSheet> {
  static const List<String> _driverReasons = <String>[
    'Passenger no-show',
    'Wrong pickup location',
    'Emergency / Safety concern',
    'Vehicle issue',
  ];
  static const List<String> _customerReasons = <String>[
    'Customer canceled from app',
    'Customer not reachable',
    'Customer changed plan',
    'Customer booked by mistake',
  ];

  String _cancelType = 'Driver';
  String _selectedReason = _driverReasons.first;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.neutralCCC,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Select Cancellation Reason',
              style: TextStyle(
                fontSize: 32 / 2,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral333,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'PROFESSIONAL STANDARDS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.emerald,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                Expanded(
                  child: _CancelTypeChip(
                    label: 'Driver',
                    selected: _cancelType == 'Driver',
                    onTap: () {
                      setState(() {
                        _cancelType = 'Driver';
                        _selectedReason = _driverReasons.first;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CancelTypeChip(
                    label: 'Customer',
                    selected: _cancelType == 'Customer',
                    onTap: () {
                      setState(() {
                        _cancelType = 'Customer';
                        _selectedReason = _customerReasons.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (String? value) {
                if (value == null) return;
                setState(() => _selectedReason = value);
              },
              child: Column(
                children: (_cancelType == 'Driver'
                        ? _driverReasons
                        : _customerReasons)
                    .map(_buildReasonTile)
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cancellation Fee: \u20B900.00',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.neutral888,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        await widget.onConfirm(
                          _cancelType.toLowerCase(),
                          _selectedReason,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'CONFIRM CANCELLATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            reason,
            style: const TextStyle(
              fontSize: 19 / 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral444,
            ),
          ),
          trailing: Radio<String>(
            value: reason,
            activeColor: AppColors.emerald,
          ),
          onTap: () => setState(() => _selectedReason = reason),
        ),
        const Divider(height: 1, color: AppColors.strokeLight),
      ],
    );
  }
}

class _CancelTypeChip extends StatelessWidget {
  const _CancelTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.emerald : AppColors.neutralCCC,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.neutral666,
          ),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.onChatTap, required this.onCallTap});

  final VoidCallback onChatTap;
  final VoidCallback onCallTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceF5,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset('assets/image/profile.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sam Yogi',
                  style: TextStyle(
                    fontSize: 26 / 2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral333,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Icon(Icons.star, size: 12, color: AppColors.starYellow),
                    SizedBox(width: 4),
                    Text(
                      '4.9  Rating',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral666,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _CircleIconButton(icon: Icons.chat_bubble_outline, onTap: onChatTap),
          const SizedBox(width: 8),
          _CircleIconButton(icon: Icons.call, onTap: onCallTap),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.neutral555),
        ),
      ),
    );
  }
}

class _TripMetrics extends StatelessWidget {
  const _TripMetrics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        _MetricItem(label: 'Fare', value: '\u20B91,250'),
        _MetricDivider(),
        _MetricItem(label: 'Distance', value: '2.1 km'),
        _MetricDivider(),
        _MetricItem(label: 'Arrival', value: '4 mins'),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.surfaceF0,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.neutral888,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16 / 1.05,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral333,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupDropSection extends StatelessWidget {
  const _PickupDropSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 20,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 2),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.surfaceFDF8,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emerald, width: 1.5),
                ),
              ),
              Container(width: 1.2, height: 34, color: AppColors.neutralAAA),
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.neutral333,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pickup',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral666,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '42, I-Block, Arumbakkam, Chennai-106',
                style: TextStyle(
                  fontSize: 21 / 2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral333,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Dropoff',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral666,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '13, vinobaji St, KamarajarNagar, NGO...',
                style: TextStyle(
                  fontSize: 21 / 2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral333,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

