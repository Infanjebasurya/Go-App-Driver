import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/home_trip_resume_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/storage/trip_session_store.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/ride_complete/data/repositories/ride_complete_repository_impl.dart';
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
  @override
  void initState() {
    super.initState();
    unawaited(HomeTripResumeStore.setStage(HomeTripResumeStage.rideCompleted));
    if (Env.mockApi) {
      unawaited(HomeTripResumeStore.markForceHomeOnNextLaunch());
    }
    final summary = context.read<RideCompletedCubit>().state.summary;
    // B-03 FIX: markCompletedNowOrCreate was already called by
    // trip_navigation_page.dart when the captain tapped "Complete Trip".
    // Calling it again here created a duplicate trip record.
    // We only update the fare/distance labels on the existing record.
    unawaited(
      RideHistoryStore.updateLatestCompletedDetails(
        fareLabel: '\u20B9 ${summary.totalEarnings.toStringAsFixed(2)}',
        distanceLabel: '${summary.distanceKm.toStringAsFixed(1)} km',
      ),
    );
    // TripSessionStore: cache the full payment breakdown from the server.
    unawaited(
      TripSessionStore.savePaymentDetails(
        totalEarnings: summary.totalEarnings,
        tripFare: summary.tripFare,
        tips: summary.tips,
        discountPercent: summary.discountPercent,
        discountAmount: summary.discountAmount,
        paymentLink: summary.paymentLink,
        method: 'cash',
      ),
    );
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
                          // TripSessionStore: captain confirmed payment received.
                          unawaited(TripSessionStore.markPaymentReceived());
                          unawaited(
                            HomeTripResumeStore.setStage(
                              HomeTripResumeStage.rateExperience,
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RateExperienceScreen(),
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
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
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
