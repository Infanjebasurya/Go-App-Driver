import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/location/location_permission_guard.dart';
import 'package:goapp/core/utils/wallet_display.dart';
import 'package:goapp/core/widgets/location_disabled_banner.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/earnings/presentation/pages/wallet_page.dart';
import 'package:goapp/core/di/injection.dart';
import '../cubit/driver_status_cubit.dart';
import '../cubit/driver_status_state.dart';
import 'map_widget.dart';
import 'status_header.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class OnlineContent extends StatefulWidget {
  const OnlineContent({super.key});

  @override
  State<OnlineContent> createState() => _OnlineContentState();
}

class _OnlineContentState extends State<OnlineContent> {
  late final MapWidgetController _mapController;
  LocationIssue? _locationIssue;

  @override
  void initState() {
    super.initState();
    _mapController = MapWidgetController();
    _mapController.bindLocationIssueListener((issue) {
      if (!mounted) return;
      if (_locationIssue == issue) return;

      final phase = SchedulerBinding.instance.schedulerPhase;
      final shouldDefer =
          phase == SchedulerPhase.transientCallbacks ||
          phase == SchedulerPhase.midFrameMicrotasks ||
          phase == SchedulerPhase.persistentCallbacks;

      if (shouldDefer) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _locationIssue == issue) return;
          setState(() => _locationIssue = issue);
        });
        return;
      }

      setState(() => _locationIssue = issue);
    });
  }

  @override
  void dispose() {
    _mapController.bindLocationIssueListener(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverCubit, DriverState>(
      builder: (context, state) {
        return Stack(
          children: [
            MapWidget(controller: _mapController),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: const DriverAppBar(),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: _OnlineStatusBanner(),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: _EarningsCard(state: state),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: _BottomWalletCard(state: state),
            ),

            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              right: 16,
              child: _GpsButton(
                onTap: () {
                  _mapController.recenterToCurrentLocation();
                },
              ),
            ),
            if (_locationIssue != null)
              Positioned(
                left: 0,
                right: 0,
                top: 62,
                child: SafeArea(
                  bottom: false,
                  child: LocationDisabledBanner(
                    issue: _locationIssue!,
                    onActionTap: () {
                      if (_locationIssue == LocationIssue.serviceDisabled) {
                        sl<LocationPermissionGuard>().openLocationSettings();
                      } else {
                        sl<LocationPermissionGuard>().openAppSettings();
                      }
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OnlineStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.hexFF008051, AppColors.emerald],
        ),
        color: AppColors.earningsAccentSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.earningsAccentLine, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "You're Online",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.white,
                ),
              ),
              Text(
                'Ready to receive orders',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final DriverState state;
  const _EarningsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<DriverCubit>().toggleEarningsExpanded(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.black45,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S EARNINGS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '₹ ${state.totalEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black87,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  state.isEarningsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.black45,
                ),
              ],
            ),
            if (state.isEarningsExpanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.warmGray),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(
                    icon: Icons.directions_car_outlined,
                    value: '${state.tripsCompleted} Trips',
                    label: 'Completed',
                  ),
                  const SizedBox(width: 20),
                  _MiniStat(
                    icon: Icons.access_time,
                    value: state.onlineHours,
                    label: 'Online Hours',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: AuthUiColors.brandGreen, size: 24),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black87,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black45,
          ),
        ),
      ],
    );
  }
}

class _BottomWalletCard extends StatelessWidget {
  final DriverState state;
  const _BottomWalletCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final double displayBalance = walletDisplayBalance(state.walletBalance);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceF5,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
              color: AppColors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black45,
                  ),
                ),
                Text(
                  '\u20B9 ${displayBalance.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.black87,
                  ),
                ),
                if (state.isWalletAtOrBelowDutyThreshold)
                  Text(
                    'Wallet reached limit (-Rs ${kMinimumDutyWalletBalance.abs().toStringAsFixed(0)}). Add money to continue rides.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ShadowButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WalletPage())).then((_) {
                if (!context.mounted) return;
                context.read<DriverCubit>().refreshDashboardMetrics();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthUiColors.brandGreen,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Add Money',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsButton extends StatelessWidget {
  const _GpsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      shape: const CircleBorder(),
      onPressed: onTap,
      backgroundColor: AppColors.white,
      elevation: 4,
      child: const Icon(Icons.my_location, color: AppColors.black54, size: 20),
    );
  }
}









