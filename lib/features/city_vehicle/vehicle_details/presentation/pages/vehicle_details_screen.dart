import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/cubit/vehicle_details_cubit.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/model/vehicle_details_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/widget/selection_bottom_sheet.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/widget/underline_input_field.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/widget/vehicle_photo_upload.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';
import 'package:goapp/features/document_verify/presentation/pages/verification_screen.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({
    super.key,
    required this.vehicleType,
  });

  final VehicleType vehicleType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VehicleDetailsCubit(vehicleType: vehicleType),
      child: const _VehicleDetailsView(),
    );
  }
}

class _VehicleDetailsView extends StatefulWidget {
  const _VehicleDetailsView();

  @override
  State<_VehicleDetailsView> createState() => _VehicleDetailsViewState();
}

class _VehicleDetailsViewState extends State<_VehicleDetailsView> {
  final _modelController = TextEditingController();
  final _bikeTypeController = TextEditingController();
  final _seatController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    _bikeTypeController.dispose();
    _seatController.dispose();
    _fuelTypeController.dispose();
    _yearController.dispose();
    super.dispose();
  }

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
      body: BlocConsumer<VehicleDetailsCubit, VehicleDetailsState>(
        listener: (context, state) {
          _bikeTypeController.text = state.bikeTypeDisplay;
          _seatController.text = state.seatDisplay;
          _fuelTypeController.text = state.fuelTypeDisplay;
          if (state.isSubmitted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const VerificationScreen(),
              ),
            );
            context.read<VehicleDetailsCubit>().clearSuccess();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2236),
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fill in your vehicle details to proceed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      VehiclePhotoUpload(
                        hasPhoto: state.hasPhoto,
                        vehicleType: state.vehicleType,
                        onTap: () => context.read<VehicleDetailsCubit>().pickPhoto(),
                        onRemove: () => context.read<VehicleDetailsCubit>().removePhoto(),
                      ),
                      const SizedBox(height: 28),
                      if (state.vehicleType != VehicleType.auto) ...[
                        UnderlineInputField(
                          label: 'Model Name',
                          hint: 'e.g., TVS Ntorq 125cc',
                          controller: _modelController,
                          errorText: state.errors.modelName,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 22),
                      ],
                      if (state.vehicleType == VehicleType.bike) ...[
                        UnderlineInputField(
                          label: 'Bike Type',
                          hint: 'e.g., Scooter',
                          controller: _bikeTypeController,
                          errorText: state.errors.bikeType,
                          readOnly: true,
                          onTap: () => _showBikeTypeSheet(context, state),
                        ),
                        const SizedBox(height: 22),
                      ],
                      if (state.vehicleType == VehicleType.cab) ...[
                        UnderlineInputField(
                          label: 'Select Seats',
                          hint: 'Choose seats',
                          controller: _seatController,
                          errorText: state.errors.seatOption,
                          readOnly: true,
                          onTap: () => _showSeatSheet(context, state),
                        ),
                        const SizedBox(height: 22),
                      ],
                      UnderlineInputField(
                        label: 'Fuel Type',
                        hint: 'Select Fuel',
                        controller: _fuelTypeController,
                        errorText: state.errors.fuelType,
                        readOnly: true,
                        onTap: () => _showFuelTypeSheet(context, state),
                      ),
                      const SizedBox(height: 22),
                      UnderlineInputField(
                        label: 'Year',
                        hint: 'e.g., ${DateTime.now().year}',
                        controller: _yearController,
                        errorText: state.errors.year,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              _ContinueButton(
                isSubmitting: state.isSubmitting,
                onTap: () {
                  final cubit = context.read<VehicleDetailsCubit>();
                  cubit.updateModelName(_modelController.text);
                  cubit.updateYear(_yearController.text);
                  cubit.submit();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBikeTypeSheet(BuildContext context, VehicleDetailsState state) {
    showSelectionSheet<BikeType>(
      context: context,
      title: 'Select Bike Type',
      options: BikeType.values,
      selected: state.selectedBikeType,
      labelBuilder: (t) => t.label,
      onSelect: (t) => context.read<VehicleDetailsCubit>().selectBikeType(t),
    );
  }

  void _showFuelTypeSheet(BuildContext context, VehicleDetailsState state) {
    showSelectionSheet<FuelType>(
      context: context,
      title: 'Select Fuel',
      options: FuelType.values,
      selected: state.selectedFuelType,
      labelBuilder: (t) => t.label,
      onSelect: (t) => context.read<VehicleDetailsCubit>().selectFuelType(t),
    );
  }

  void _showSeatSheet(BuildContext context, VehicleDetailsState state) {
    showSelectionSheet<SeatOption>(
      context: context,
      title: 'Select Seats',
      options: SeatOption.values,
      selected: state.selectedSeatOption,
      labelBuilder: (t) => t.label,
      onSelect: (t) => context.read<VehicleDetailsCubit>().selectSeatOption(t),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onTap;

  const _ContinueButton({required this.isSubmitting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F4F8))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          key: const Key('continue_button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          onPressed: isSubmitting ? null : onTap,
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
      ),
    );
  }
}
