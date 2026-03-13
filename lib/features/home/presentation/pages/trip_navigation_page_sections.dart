part of 'trip_navigation_page.dart';

class _TurnIconBadge extends StatelessWidget {
  const _TurnIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.turn_right_rounded, color: AppColors.white),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'SOS',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationButton extends StatelessWidget {
  const _CurrentLocationButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.my_location, color: AppColors.neutral666),
    );
  }
}

class _ReachedCustomerSheet extends StatelessWidget {
  const _ReachedCustomerSheet({
    required this.onCompleteTap,
    required this.fareLabel,
    required this.distanceLabel,
    required this.pickupAddress,
    required this.dropAddress,
  });

  final VoidCallback onCompleteTap;
  final String fareLabel;
  final String distanceLabel;
  final String pickupAddress;
  final String dropAddress;

  @override
  Widget build(BuildContext context) {
    final displayName = ProfileDisplayStore.displayName();
    final profilePath = ProfileDisplayStore.photoPath();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.neutralCCC,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reached Customer location',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.emerald,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.emerald, width: 2),
                  ),
                  child: ClipOval(
                    child: profilePath != null
                        ? Image.file(File(profilePath), fit: BoxFit.contain)
                        : Image.asset(
                            'assets/image/profile.png',
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral333,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 13,
                            color: AppColors.starYellow,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4.9 Rating',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral888,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral888,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      distanceLabel,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral333,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            _PickupDropInfo(
              pickupAddress: pickupAddress,
              dropAddress: dropAddress,
            ),
            const SizedBox(height: 16),
            _SlideToCompleteButton(onCompleted: onCompleteTap),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Ride in progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral666,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Total Fare: $fareLabel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral555,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideToCompleteButton extends StatefulWidget {
  const _SlideToCompleteButton({required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<_SlideToCompleteButton> createState() => _SlideToCompleteButtonState();
}

class _SlideToCompleteButtonState extends State<_SlideToCompleteButton> {
  static const double _thumbSize = 44;
  static const double _padding = 2;
  static const double _completeThreshold = 0.92;

  double _dragX = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxDrag =
              constraints.maxWidth - _thumbSize - (_padding * 2);
          final double clampedDrag = _dragX.clamp(0, maxDrag);

          return GestureDetector(
            onHorizontalDragUpdate: _completed
                ? null
                : (DragUpdateDetails details) {
                    setState(() {
                      _dragX = (_dragX + details.delta.dx).clamp(0, maxDrag);
                    });
                  },
            onHorizontalDragEnd: _completed
                ? null
                : (_) {
                    final bool didComplete =
                        maxDrag > 0 &&
                        (clampedDrag / maxDrag) >= _completeThreshold;
                    if (didComplete) {
                      setState(() {
                        _completed = true;
                        _dragX = maxDrag;
                      });
                      widget.onCompleted();
                      return;
                    }
                    setState(() => _dragX = 0);
                  },
            child: Stack(
              children: <Widget>[
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Slide to Complete',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  left: _padding + clampedDrag,
                  top: _padding,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PickupDropInfo extends StatelessWidget {
  const _PickupDropInfo({
    required this.pickupAddress,
    required this.dropAddress,
  });

  final String pickupAddress;
  final String dropAddress;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 18,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 3),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.surfaceFDF8,
                  border: Border.all(color: AppColors.emerald, width: 1.5),
                  shape: BoxShape.circle,
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
        Expanded(
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
                pickupAddress,
                style: TextStyle(
                  fontSize: 11.5,
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
                dropAddress,
                style: TextStyle(
                  fontSize: 11.5,
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
