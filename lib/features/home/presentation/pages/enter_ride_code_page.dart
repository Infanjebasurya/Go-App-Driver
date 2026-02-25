import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/permissions/notification_permission_helper.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/home/presentation/cubit/enter_ride_code_cubit.dart';
import 'package:goapp/features/home/presentation/cubit/enter_ride_code_state.dart';
import 'package:goapp/features/home/presentation/pages/passenger_onboard_page.dart';
import 'package:goapp/features/notifications/presentation/model/notifications_feed.dart';

class EnterRideCodePage extends StatelessWidget {
  const EnterRideCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EnterRideCodeCubit>(
      create: (_) => EnterRideCodeCubit(),
      child: const _EnterRideCodeView(),
    );
  }
}

class _EnterRideCodeView extends StatefulWidget {
  const _EnterRideCodeView();

  @override
  State<_EnterRideCodeView> createState() => _EnterRideCodeViewState();
}

class _EnterRideCodeViewState extends State<_EnterRideCodeView> {
  @override
  void initState() {
    super.initState();
    unawaited(NotificationPermissionHelper.ensureRequestedOnce());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceF5,
      body: SafeArea(
        child: BlocBuilder<EnterRideCodeCubit, EnterRideCodeState>(
          builder: (BuildContext context, EnterRideCodeState state) {
            final cubit = context.read<EnterRideCodeCubit>();
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Enter Ride Code',
                  style: TextStyle(
                    fontSize: 22.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral333,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ask the passenger for the 4-digit\nstart code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.6,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral888,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(4, (int index) {
                    final bool hasDigit = index < state.digits.length;
                    return Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceF0,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          hasDigit ? state.digits[index] : '·',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: hasDigit
                                ? AppColors.neutral333
                                : AppColors.neutralAAA,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 26),
                const Text(
                  "Can't find code?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningText,
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: state.canStart
                          ? () {
                              NotificationsFeed.add(
                                title: 'Trip started with rider',
                                message:
                                    'OTP verified. Rider notified that trip has started.',
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const PassengerOnboardPage(),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        'Start Trip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: <Widget>[
                      _KeypadRow(
                        labels: const <String>['1', '2', '3'],
                        onPressed: cubit.addDigit,
                      ),
                      _KeypadRow(
                        labels: const <String>['4', '5', '6'],
                        onPressed: cubit.addDigit,
                      ),
                      _KeypadRow(
                        labels: const <String>['7', '8', '9'],
                        onPressed: cubit.addDigit,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          const Expanded(child: SizedBox()),
                          Expanded(
                            child: _KeypadNumberButton(
                              label: '0',
                              onTap: () => cubit.addDigit('0'),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.backspace, size: 22),
                                onPressed: cubit.backspace,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KeypadRow extends StatelessWidget {
  const _KeypadRow({required this.labels, required this.onPressed});

  final List<String> labels;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: labels
          .map(
            (String label) => Expanded(
              child: _KeypadNumberButton(
                label: label,
                onTap: () => onPressed(label),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _KeypadNumberButton extends StatelessWidget {
  const _KeypadNumberButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neutral333,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        child: Text(label),
      ),
    );
  }
}
