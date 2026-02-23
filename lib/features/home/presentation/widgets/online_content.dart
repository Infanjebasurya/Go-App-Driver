

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/earnings/presentation/pages/wallet_page.dart';
import '../cubit/driver_status_cubit.dart';
import '../cubit/driver_status_state.dart';
import 'map_widget.dart';
import 'status_header.dart';

class OnlineContent extends StatelessWidget {
  const OnlineContent({super.key});

  @override
  Widget build(BuildContext context) {
    final MapWidgetController mapController = MapWidgetController();
    return BlocBuilder<DriverCubit, DriverState>(
      builder: (context, state) {
        return Stack(
          children: [
            MapWidget(controller: mapController),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              bottom: 20,
              child: _BottomWalletCard(state: state),
            ),

            Positioned(
              bottom: 100,
              right: 16,
              child: _GpsButton(
                onTap: () {
                  mapController.recenterToCurrentLocation();
                },
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
          colors: [Color(0xFF008051), Color(0xFF00A86B)],
        ),
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
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
                  color: Colors.white,
                ),
              ),
              Text(
                'Ready to receive orders',
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w400, color: Colors.white70),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 18, color: Colors.black45),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S EARNINGS",
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600, color: Colors.black45, letterSpacing: 0.5),
                    ),
                    Text(
                      '₹ ${state.totalEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  state.isEarningsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black45,
                ),
              ],
            ),
            if (state.isEarningsExpanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1,color: AppColors.warmGray,),
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
  const _MiniStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: AuthUiColors.brandGreen, size: 24),
            const SizedBox(width: 6),
            Text(value,
                style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w500, color: Colors.black45)),
      ],
    );

  }
}

class _BottomWalletCard extends StatelessWidget {
  final DriverState state;
  const _BottomWalletCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isNegative = state.walletBalance < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 20,
                color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45),
              ),
              Text(
                '${isNegative ? '-' : ''}₹ ${state.walletBalance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isNegative ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WalletPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthUiColors.brandGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Money'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Amount (₹)',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<DriverCubit>().addMoneyFromInput(controller.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AuthUiColors.brandGreen,),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.my_location, color: Colors.black54, size: 20),
    );
  }
}
