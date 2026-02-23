import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/model/city_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/pages/vehicle_details_screen.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/cubit/vehicle_selection_cubit.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/widgets/vehicle_card.dart';

class VehicleSelectionScreen extends StatelessWidget {
  final City selectedCity;

  const VehicleSelectionScreen({super.key, required this.selectedCity});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VehicleSelectionCubit(),
      child: _VehicleSelectionView(selectedCity: selectedCity),
    );
  }
}

class _VehicleSelectionView extends StatelessWidget {
  final City selectedCity;

  const _VehicleSelectionView({required this.selectedCity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(
        title: 'GoApp',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF0F4F8)),
        ),
      ),
      body: BlocBuilder<VehicleSelectionCubit, VehicleSelectionState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Vehicle Type',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2236),
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select the vehicle you want do drive with',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: kVehicles.map((vehicle) {
                    return VehicleCard(
                      key: ValueKey(vehicle.type),
                      vehicle: vehicle,
                      isSelected: state.isSelected(vehicle),
                      onTap: () => context.read<VehicleSelectionCubit>().selectVehicle(vehicle),
                    );
                  }).toList(),
                ),
              ),
              _ConfirmButton(
                enabled: state.hasSelection,
                vehicleLabel: state.selectedVehicle?.label,
                onTap: () {
                  if (state.hasSelection) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailsScreen(
                          vehicleType: state.selectedVehicle!.type,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final String? vehicleLabel;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.enabled,
    this.vehicleLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.45,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const Key('confirm_vehicle_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: enabled ? onTap : null,
            child: Text(
              enabled && vehicleLabel != null
                  ? 'Continue with $vehicleLabel'
                  : 'Select a Vehicle',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
