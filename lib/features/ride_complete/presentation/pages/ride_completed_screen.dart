import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/driver_wallet_store.dart';
import 'package:goapp/core/storage/home_trip_resume_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/storage/trip_session_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/ride_complete/data/repositories/ride_complete_repository_impl.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/domain/usecases/get_ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/ride_completed_cubit.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/ride_completed_state.dart';
import 'package:goapp/features/ride_complete/presentation/pages/rate_experience_screen.dart';
import 'package:goapp/core/utils/env.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RideCompletedScreen extends StatelessWidget {
  const RideCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RideCompleteRepositoryImpl();
    return BlocProvider<RideCompletedCubit>(
      create: (_) => RideCompletedCubit(GetRideCompletionSummary(repository)),
      child: const _RideCompletedView(),
    );
  }
}

class _RideCompletedView extends StatefulWidget {
  const _RideCompletedView();

  @override
  State<_RideCompletedView> createState() => _RideCompletedViewState();
}

class _RideCompletedViewState extends State<_RideCompletedView> {
  static const double _gstRate = 0.05;

  @override
  void initState() {
    super.initState();
    unawaited(HomeTripResumeStore.setStage(HomeTripResumeStage.rideCompleted));
    if (Env.mockApi) {
      unawaited(HomeTripResumeStore.markForceHomeOnNextLaunch());
    }
    unawaited(_syncSummaryAndPersist());
  }

  Future<void> _syncSummaryAndPersist() async {
    final RideCompletedCubit cubit = context.read<RideCompletedCubit>();
    RideCompletionSummary summary = cubit.state.summary;
    final TripSession? session = await TripSessionStore.loadActive();
    if (session != null && session.fareLabel.isNotEmpty) {
      final double acceptedFare = _parseCurrency(session.fareLabel);
      final double acceptedDistance = _parseDistanceKm(session.distanceLabel);
      final bool shouldUseAcceptedFare = acceptedFare > 0;
      final double nextTripFare = shouldUseAcceptedFare
          ? acceptedFare
          : summary.tripFare;
      final double nextTotalEarnings = shouldUseAcceptedFare
          ? acceptedFare
          : (summary.totalEarnings > 0 ? summary.totalEarnings : nextTripFare);
      summary = RideCompletionSummary(
        totalEarnings: nextTotalEarnings,
        distanceKm: acceptedDistance > 0 ? acceptedDistance : summary.distanceKm,
        tripFare: nextTripFare,
        tips: shouldUseAcceptedFare ? 0 : summary.tips,
        discountPercent: shouldUseAcceptedFare ? 0 : summary.discountPercent,
        discountAmount: shouldUseAcceptedFare ? 0 : summary.discountAmount,
        paymentLink: summary.paymentLink,
        driverName: summary.driverName,
        driverRating: summary.driverRating,
        avatarAssetPath: summary.avatarAssetPath,
      );
      cubit.setSummary(summary);
    }

    if (!mounted) return;
    final double tripAmount = summary.tripFare > 0
        ? summary.tripFare
        : _parseCurrency(session?.fareLabel);
    final double incentiveAmount = _deriveIncentive(summary, tripAmount);
    final double grossEarning = _deriveNetEarning(
      summary: summary,
      tripAmount: tripAmount,
      incentiveAmount: incentiveAmount,
    );
    final double gstAmount = _gstAmount(_collectableSubTotal(summary));
    final double netEarning = _earningExcludingGst(
      grossEarning: grossEarning,
      gstAmount: gstAmount,
    );

    summary = RideCompletionSummary(
      totalEarnings: netEarning,
      distanceKm: summary.distanceKm,
      tripFare: summary.tripFare,
      tips: summary.tips,
      discountPercent: summary.discountPercent,
      discountAmount: summary.discountAmount,
      paymentLink: summary.paymentLink,
      driverName: summary.driverName,
      driverRating: summary.driverRating,
      avatarAssetPath: summary.avatarAssetPath,
    );
    cubit.setSummary(summary);

    await RideHistoryStore.updateLatestCompletedDetails(
      fareLabel: '\u20B9 ${netEarning.toStringAsFixed(2)}',
      distanceLabel: '${summary.distanceKm.toStringAsFixed(1)} km',
      tripAmount: tripAmount,
      incentiveAmount: incentiveAmount,
      cancellationFeeAmount: 0,
      netEarningAmount: netEarning,
    );
    await TripSessionStore.savePaymentDetails(
      totalEarnings: netEarning,
      tripFare: tripAmount,
      tips: summary.tips,
      discountPercent: summary.discountPercent,
      discountAmount: summary.discountAmount,
      paymentLink: summary.paymentLink,
      method: 'cash',
    );
  }

  double _earningExcludingGst({
    required double grossEarning,
    required double gstAmount,
  }) {
    final double next = _round2(grossEarning - gstAmount);
    return next > 0 ? next : 0;
  }

  double _parseCurrency(String? raw) {
    if (raw == null || raw.isEmpty) return 0;
    final String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }

  double _parseDistanceKm(String? raw) {
    if (raw == null || raw.isEmpty) return 0;
    final String cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }

  double _deriveIncentive(RideCompletionSummary summary, double tripAmount) {
    final double computed =
        summary.totalEarnings - tripAmount + summary.discountAmount;
    if (computed > 0) return computed;
    return 0;
  }

  double _deriveNetEarning({
    required RideCompletionSummary summary,
    required double tripAmount,
    required double incentiveAmount,
  }) {
    final double explicit = summary.totalEarnings;
    if (explicit > 0) return explicit;
    final double net = tripAmount + incentiveAmount - summary.discountAmount;
    return net > 0 ? net : 0;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: BlocBuilder<RideCompletedCubit, RideCompletedState>(
            builder: (BuildContext context, RideCompletedState state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        final double subTotal = _collectableSubTotal(
                          state.summary,
                        );
                        final double gstAmount = _gstAmount(subTotal);
                        final double totalCollectable = subTotal;
                        return Column(
                          children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ride Completed',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Earnings',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '\u20B9 ${state.summary.totalEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFareRow(
                            'Distance',
                            '${state.summary.distanceKm.toStringAsFixed(1)} km',
                          ),
                          const SizedBox(height: 16),
                          _buildFareRow(
                            'Trip Fare',
                            state.summary.tripFare.toStringAsFixed(2),
                          ),
                          const SizedBox(height: 16),
                          _buildFareRow(
                            'Tips',
                            '\u20B9${state.summary.tips.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 16),
                          _buildFareRow(
                            'Discount ${state.summary.discountPercent.toStringAsFixed(0)}%',
                            '-\u20B9${state.summary.discountAmount.toStringAsFixed(2)}',
                            isDiscount: true,
                          ),
                          const SizedBox(height: 16),
                          _buildFareRow(
                            'GST (5%)',
                            '\u20B9${gstAmount.toStringAsFixed(2)} (included)',
                          ),
                          const SizedBox(height: 16),
                          _buildFareRow(
                            'Total Collectable',
                            '\u20B9${totalCollectable.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              context
                                  .read<RideCompletedCubit>()
                                  .toggleQrExpanded();
                            },
                            borderRadius: state.isQrExpanded
                                ? const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  )
                                : BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Generate QR Code',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Show to Customer',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    state.isQrExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (state.isQrExpanded)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 24.0,
                                left: 24.0,
                                right: 24.0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: QrImageView(
                                  data: state.summary.paymentLink,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          unawaited(
                            _onCollectPaymentTap(
                              viaQr: false,
                              summary: state.summary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Collect Cash',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          unawaited(
                            _onCollectPaymentTap(
                              viaQr: true,
                              summary: state.summary,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.emerald),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Collect via QR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emerald,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.emerald,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onCollectPaymentTap({
    required bool viaQr,
    required RideCompletionSummary summary,
  }) async {
    final double subTotal = _collectableSubTotal(summary);
    final double gstAmount = _gstAmount(subTotal);
    final double totalCollectable = subTotal;

    if (viaQr) {
      await DriverWalletStore.addAmount(totalCollectable);
      final double updated = await DriverWalletStore.loadBalance();
      final double next = _round2(updated - gstAmount);
      final double bounded =
          next < DriverWalletStore.minAllowedNegativeBalance
          ? DriverWalletStore.minAllowedNegativeBalance
          : next;
      await DriverWalletStore.saveBalance(bounded);
      await TripSessionStore.markPaymentReceived(method: 'online');
    } else {
      final double current = await DriverWalletStore.loadBalance();
      final double next = _round2(current - gstAmount);
      final double bounded =
          next < DriverWalletStore.minAllowedNegativeBalance
          ? DriverWalletStore.minAllowedNegativeBalance
          : next;
      await DriverWalletStore.saveBalance(bounded);
      await TripSessionStore.markPaymentReceived(method: 'cash');
    }

    await HomeTripResumeStore.setStage(HomeTripResumeStage.rateExperience);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RateExperienceScreen()),
    );
  }

  double _collectableSubTotal(RideCompletionSummary summary) {
    final double value =
        summary.tripFare + summary.tips - summary.discountAmount;
    if (value <= 0) return 0;
    return _round2(value);
  }

  double _gstAmount(double subTotal) {
    if (subTotal <= 0) return 0;
    return _round2((subTotal * _gstRate) / (1 + _gstRate));
  }

  double _round2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  Widget _buildFareRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDiscount ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }
}

