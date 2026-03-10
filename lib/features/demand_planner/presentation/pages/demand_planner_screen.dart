import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/demand_planner/presentation/cubit/demand_planner_cubit.dart';
import 'package:goapp/features/demand_planner/presentation/cubit/demand_planner_state.dart';
import 'package:goapp/features/demand_planner/presentation/model/peak_hour_model.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/theme/app_colors.dart';

class DemandPlannerScreen extends StatelessWidget {
  const DemandPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemandPlannerCubit(),
      child: const _DemandPlannerView(),
    );
  }
}

class _DemandPlannerView extends StatelessWidget {
  const _DemandPlannerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Demand Planner'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.hexFFEEEEEE, height: 1),
        ),
      ),
      body: BlocBuilder<DemandPlannerCubit, DemandPlannerState>(
        builder: (context, state) {
          if (state is DemandPlannerLoading || state is DemandPlannerInitial) {
            return const _LoadingView();
          }
          if (state is DemandPlannerLoaded) {
            return _LoadedView(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedView extends StatefulWidget {
  final DemandPlannerLoaded state;

  const _LoadedView({required this.state});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const minFraction = 0.46;
    const maxFraction = 0.85;

    return Stack(
      children: [
        SizedBox(
          height: size.height * (1 - minFraction + 0.06),
          width: double.infinity,
          child: const _SurgeMapWidget(),
        ),
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: minFraction,
          minChildSize: minFraction,
          maxChildSize: maxFraction,
          snap: true,
          snapSizes: const [minFraction, maxFraction],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.hex18000000,
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.hexFFDDDDDD,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  _SurgeToggleCard(
                    enabled: widget.state.surgeNotificationsEnabled,
                    onToggle: () => context
                        .read<DemandPlannerCubit>()
                        .toggleSurgeNotifications(),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'UPCOMING PEAK HOURS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.hexFF1A1A1A,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.state.peakHours.map(
                    (ph) => _PeakHourRow(peakHour: ph),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SurgeMapWidget extends StatelessWidget {
  const _SurgeMapWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(painter: _MapPainter(), child: Container()),
        const Positioned(
          top: 60,
          left: 60,
          child: _SurgeBlob(size: 180, opacity: 0.18),
        ),
        const Positioned(
          top: 30,
          right: 40,
          child: _SurgeBlob(size: 120, opacity: 0.12),
        ),
        const Positioned(top: 130, left: 90, child: _SurgeDot()),
        const Positioned(top: 170, left: 180, child: _SurgeDot()),
        const Positioned(top: 90, right: 80, child: _SurgeDot()),
        const Positioned(top: 170, right: 30, child: _SurgeDot()),
        const Positioned(top: 200, right: 100, child: _SurgeDot()),
        Positioned(
          right: 12,
          bottom: 70,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location,
              color: AppColors.hexFF555555,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _SurgeBlob extends StatelessWidget {
  final double size;
  final double opacity;

  const _SurgeBlob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AuthUiColors.brandGreen.withValues(alpha: opacity),
      ),
    );
  }
}

class _SurgeDot extends StatelessWidget {
  const _SurgeDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AuthUiColors.brandGreen,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.hexFFE8E8E8
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bgPaint = Paint()..color = AppColors.hexFFF5F5F5;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final rng = math.Random(42);
    for (int i = 0; i < 18; i++) {
      final path = Path();
      final sx = rng.nextDouble() * size.width;
      final sy = rng.nextDouble() * size.height;
      path.moveTo(sx, sy);
      final ex = sx + (rng.nextDouble() - 0.4) * 200;
      final ey = sy + (rng.nextDouble() - 0.4) * 200;
      final cx = (sx + ex) / 2 + (rng.nextDouble() - 0.5) * 60;
      final cy = (sy + ey) / 2 + (rng.nextDouble() - 0.5) * 60;
      path.quadraticBezierTo(cx, cy, ex, ey);
      paint.strokeWidth = rng.nextDouble() < 0.3 ? 3.0 : 1.5;
      canvas.drawPath(path, paint);
    }

    final blockPaint = Paint()
      ..color = AppColors.hexFFDDDDDD
      ..style = PaintingStyle.fill;
    final rng2 = math.Random(7);
    for (int i = 0; i < 12; i++) {
      final x = rng2.nextDouble() * size.width;
      final y = rng2.nextDouble() * size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            y,
            20 + rng2.nextDouble() * 35,
            15 + rng2.nextDouble() * 25,
          ),
          const Radius.circular(3),
        ),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SurgeToggleCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onToggle;

  const _SurgeToggleCard({required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hexFFEEEEEE),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.hexFF00A86B.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: enabled
                  ? AuthUiColors.brandGreen
                  : AppColors.hexFF00A86B,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notify Me for Surge',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.hexFF1A1A1A,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Alerts for >1.2x multipliers',
                  style: TextStyle(fontSize: 12, color: AppColors.gray.shade500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 26,
              decoration: BoxDecoration(
                color: enabled
                    ? AuthUiColors.brandGreen
                    : AppColors.hexFFCCCCCC,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: enabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.hex22000000,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeakHourRow extends StatelessWidget {
  final PeakHour peakHour;

  const _PeakHourRow({required this.peakHour});

  Color get _demandColor {
    switch (peakHour.demandLevel) {
      case DemandLevel.high:
        return AuthUiColors.brandGreen;
      case DemandLevel.moderate:
        return AppColors.hexFF4CAF50;
      case DemandLevel.steady:
        return AppColors.hexFFBBBBBB;
    }
  }

  Color get _multiplierColor {
    switch (peakHour.demandLevel) {
      case DemandLevel.high:
        return AuthUiColors.brandGreen;
      case DemandLevel.moderate:
        return AppColors.hexFF4CAF50;
      case DemandLevel.steady:
        return AppColors.hexFFBBBBBB;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: peakHour.isActive
              ? AuthUiColors.brandGreen.withValues(alpha: 0.25)
              : AppColors.hexFFEEEEEE,
        ),
        boxShadow: peakHour.isActive
            ? [
                BoxShadow(
                  color: AuthUiColors.brandGreen.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peakHour.timeRange,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: peakHour.demandLevel == DemandLevel.steady
                        ? AppColors.hexFF888888
                        : AppColors.hexFF1A1A1A,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _demandColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      peakHour.demandLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: peakHour.demandLevel == DemandLevel.steady
                            ? AppColors.hexFFAAAAAA
                            : AppColors.hexFF555555,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${peakHour.multiplier}x',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: _multiplierColor,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'MULTIPLIER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: _multiplierColor.withValues(alpha: 0.8),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AuthUiColors.brandGreen),
    );
  }
}




