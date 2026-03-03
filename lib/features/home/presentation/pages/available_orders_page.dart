import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/maps/map_types.dart';
import 'package:goapp/core/storage/home_trip_resume_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/storage/trip_session_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/available_orders_state.dart';
import 'package:goapp/features/home/presentation/pages/ride_arrived_page.dart';
import 'package:vibration/vibration.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class AvailableOrdersPage extends StatefulWidget {
  const AvailableOrdersPage({super.key});

  @override
  State<AvailableOrdersPage> createState() => _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage>
    with WidgetsBindingObserver {
  bool _playedInitialAlert = false;
  bool _acceptedOrder = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final LocationPermissionGuard _locationGuard =
      const LocationPermissionGuard();
  final AvailableOrdersCubit _ordersCubit = AvailableOrdersCubit();
  LocationIssue? _locationIssue;
  bool _ordersStarted = false;
  bool _isLocationDialogVisible = false;
  int _declinedOrdersCount = 0;

  bool get _canReceiveOrders => _locationIssue == null;

  Future<void> _goToRideScreen({
    required LatLng pickupPoint,
    required LatLng dropPoint,
    required String pickupAddress,
    required String dropAddress,
    required String fareLabel,
    required String distanceLabel,
  }) async {
    if (_acceptedOrder) return;
    _acceptedOrder = true;
    _ordersCubit.stop();
    unawaited(_audioPlayer.stop());
    await RideHistoryStore.startTrip(
      pickupLocation: pickupAddress,
      dropLocation: dropAddress,
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
    );
    // TripSessionStore: record the full order details at the moment of acceptance.
    await TripSessionStore.startSession(
      pickupLatLng: TripLatLng(pickupPoint.latitude, pickupPoint.longitude),
      dropLatLng: TripLatLng(dropPoint.latitude, dropPoint.longitude),
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      fareLabel: fareLabel,
      distanceLabel: distanceLabel,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            RideArrivedPage(pickupPoint: pickupPoint, dropPoint: dropPoint),
      ),
    );
  }

  Future<void> _playIncomingOrderAlert() async {
    await Future.wait<void>(<Future<void>>[
      _playOrderSound(),
      _vibrateDevice(),
    ]);
  }

  Future<void> _vibrateDevice() async {
    try {
      final bool hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(duration: 450, amplitude: 255);
        return;
      }
      await HapticFeedback.heavyImpact();
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  Future<void> _playOrderSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource('Audio/order-sound.mp3'),
        volume: 1.0,
      );
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(
      HomeTripResumeStore.setStage(HomeTripResumeStage.availableOrders),
    );
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshLocationState(requestPermission: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ordersCubit.close();
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshLocationState());
    }
  }

  Future<void> _refreshLocationState({bool requestPermission = false}) async {
    final result = await _locationGuard.ensureReady(
      requestPermission: requestPermission,
    );
    if (!mounted) return;
    final LocationIssue? previousIssue = _locationIssue;
    setState(() => _locationIssue = result.issue);
    if (previousIssue != result.issue && result.issue != null) {
      unawaited(_showLocationBlockedDialog(result.issue!));
    }
    await _handleOrderFlowByLocation(
      previousIssue: previousIssue,
      nextIssue: result.issue,
    );
  }

  Future<void> _handleOrderFlowByLocation({
    required LocationIssue? previousIssue,
    required LocationIssue? nextIssue,
  }) async {
    if (nextIssue != null) {
      _ordersCubit.stop();
      _ordersStarted = false;
      await _audioPlayer.stop();
      return;
    }

    if (!_ordersStarted) {
      _ordersCubit.start();
      _ordersStarted = true;
    }

    if (!_playedInitialAlert && !_acceptedOrder) {
      _playedInitialAlert = true;
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted || _acceptedOrder || !_canReceiveOrders) return;
      await _playIncomingOrderAlert();
    }

    // Keep UI quiet on restore; just resume order flow.
  }

  Future<void> _onLocationDialogActionTap() async {
    final issue = _locationIssue;
    if (issue == null) return;
    if (issue == LocationIssue.serviceDisabled) {
      await _locationGuard.openLocationSettings();
    } else {
      await _locationGuard.openAppSettings();
    }
    if (!mounted) return;
    unawaited(_refreshLocationState());
  }

  Future<void> _showLocationBlockedDialog(LocationIssue issue) async {
    if (!mounted || _isLocationDialogVisible) return;
    _isLocationDialogVisible = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Location Required'),
          content: const Text(
            'Orders are paused. Enable GPS and Location permission to continue receiving orders.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _onLocationDialogActionTap();
              },
              child: Text(
                issue == LocationIssue.serviceDisabled
                    ? 'Enable GPS'
                    : 'Open Settings',
              ),
            ),
          ],
        );
      },
    );
    _isLocationDialogVisible = false;
  }

  Future<void> _handleDeclineTap() async {
    if (_declinedOrdersCount >= 2) {
      await _showDeclineLimitDialog();
      return;
    }

    _declinedOrdersCount += 1;
    _ordersCubit.stop();
  }

  Future<void> _showDeclineLimitDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Decline Limit Reached'),
          content: const Text(
            'You can decline only 2 orders while online. Accept the next order or go offline.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AvailableOrdersCubit>.value(
      value: _ordersCubit,
      child: BlocListener<AvailableOrdersCubit, AvailableOrdersState>(
        listenWhen: (previous, current) =>
            _canReceiveOrders &&
            !_acceptedOrder &&
            !previous.showSecondOrder &&
            current.showSecondOrder,
        listener: (context, state) {
          if (_acceptedOrder) return;
          // B-09 FIX: explicitly mark Future as unawaited.
          unawaited(_playIncomingOrderAlert());
        },
        child: Scaffold(
          backgroundColor: AppColors.surfaceF5,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            elevation: 0.8,
            toolbarHeight: 86,
            centerTitle: false,
            titleSpacing: 16,
            title: const _OrdersAppBarTitle(),
          ),
          body: BlocBuilder<AvailableOrdersCubit, AvailableOrdersState>(
            builder: (BuildContext context, AvailableOrdersState state) {
              final cubit = _ordersCubit;
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                children: <Widget>[
                  _OrderCard(
                    fare: '\u20B990',
                    pickupTitle: 'Arumbakkam',
                    pickupAddress: '42, MMDA Colony, Arumbakkam,\nch-106',
                    dropTitle: 'Amjikarai',
                    dropAddress:
                        '13, vinobaji St, Kamarajar Nagar, NGO\nColonyCholaimedu, Ch-94',
                    progress: _canReceiveOrders ? cubit.progressForOrder(0) : 0,
                    isEnabled: _canReceiveOrders,
                    distanceLabel: '2.5 km',
                    onDecline: _canReceiveOrders
                        ? () {
                            unawaited(_handleDeclineTap());
                          }
                        : null,
                    onAccept: () async => _goToRideScreen(
                      pickupPoint: const LatLng(13.0696, 80.2154),
                      dropPoint: const LatLng(13.0744, 80.2241),
                      pickupAddress: '42, MMDA Colony, Arumbakkam, ch-106',
                      dropAddress:
                          '13, vinobaji St, Kamarajar Nagar, NGO ColonyCholaimedu, Ch-94',
                      fareLabel: '\u20B990',
                      distanceLabel: '2.5 km',
                    ),
                  ),
                  if (state.showSecondOrder) ...<Widget>[
                    const SizedBox(height: 14),
                    _OrderCard(
                      fare: '\u20B9100',
                      // B-10 FIX: Corrected pickup address (was same as drop).
                      pickupTitle: 'Arumbakkam',
                      pickupAddress: '42, MMDA Colony, Arumbakkam,\nch-106',
                      dropTitle: 'Amjikarai',
                      dropAddress:
                          '13, vinobaji St, Kamarajar Nagar, NGO\nColonyCholaimedu, Ch-94',
                      progress: _canReceiveOrders ? cubit.progressForOrder(1) : 0,
                      isEnabled: _canReceiveOrders,
                      distanceLabel: '3.2 km',
                      onDecline: _canReceiveOrders
                          ? () {
                              unawaited(_handleDeclineTap());
                            }
                          : null,
                      onAccept: () async => _goToRideScreen(
                        pickupPoint: const LatLng(13.0721, 80.2186),
                        dropPoint: const LatLng(13.0662, 80.2103),
                        // B-10 FIX: Corrected pickup in stored record.
                        pickupAddress: '42, MMDA Colony, Arumbakkam, ch-106',
                        dropAddress:
                            '13, vinobaji St, Kamarajar Nagar, NGO ColonyCholaimedu, Ch-94',
                        fareLabel: '\u20B9100',
                        distanceLabel: '2.5 km',
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrdersAppBarTitle extends StatelessWidget {
  const _OrdersAppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Available Orders',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral333,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Tap to Accept   |   Auto-expires in 30s',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral555,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceFDF8,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.circle, size: 7, color: AppColors.emerald),
                  SizedBox(width: 6),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.fare,
    required this.pickupTitle,
    required this.pickupAddress,
    required this.dropTitle,
    required this.dropAddress,
    required this.progress,
    required this.onAccept,
    required this.isEnabled,
    // B-11 FIX: distanceLabel is now a required parameter used in the widget.
    required this.distanceLabel,
    // B-06 FIX: onDecline is wired so the button actually does something.
    this.onDecline,
  });

  final String fare;
  final String pickupTitle;
  final String pickupAddress;
  final String dropTitle;
  final String dropAddress;
  final double progress;
  final VoidCallback? onAccept;
  final bool isEnabled;
  final String distanceLabel;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: progress,
                backgroundColor: AppColors.surfaceF0,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.emerald,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fare,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.headingNavy,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'incl. tips & surge',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral888,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.navigation_outlined,
                  size: 15,
                  color: AppColors.neutral666,
                ),
                const SizedBox(width: 4),
                // B-11 FIX: Use distanceLabel parameter instead of hardcoded string.
                Text(
                  distanceLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral555,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('|', style: TextStyle(color: AppColors.neutral888)),
                const SizedBox(width: 8),
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: AppColors.neutral666,
                ),
                const SizedBox(width: 4),
                const Text(
                  '~12 mins',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral555,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LocationPoint(
              title: pickupTitle,
              subtitle: pickupAddress,
              distance: '0.8 km',
              showConnector: true,
            ),
            const SizedBox(height: 8),
            _LocationPoint(
              title: dropTitle,
              subtitle: dropAddress,
              distance: '2.8 km',
              showConnector: false,
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceF5,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      // B-06 FIX: Decline button now calls onDecline callback.
                      onPressed: isEnabled ? onDecline : null,
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral555,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ShadowButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: onAccept,
                      child: const Text(
                        'Accept Order',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _LocationPoint extends StatelessWidget {
  const _LocationPoint({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.showConnector,
  });

  final String title;
  final String subtitle;
  final String distance;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 18,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(
                  Icons.radio_button_unchecked,
                  size: 13,
                  color: AppColors.neutral666,
                ),
              ),
              if (showConnector)
                Container(width: 1.2, height: 40, color: AppColors.neutralCCC),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral333,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral666,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceF0,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            distance,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral666,
            ),
          ),
        ),
      ],
    );
  }
}

