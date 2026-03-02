import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/storage/home_trip_resume_store.dart';
import 'core/storage/registration_progress_store.dart';
import 'core/utils/env.dart';
import 'features/home/presentation/pages/available_orders_page.dart';
import 'features/home/presentation/pages/enter_ride_code_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/passenger_onboard_page.dart';
import 'features/home/presentation/pages/ride_arrived_page.dart';
import 'features/home/presentation/pages/trip_navigation_page.dart';
import 'core/maps/map_types.dart';
import 'features/home/presentation/cubit/driver_status_cubit.dart';
import 'features/onboarding/presentation/navigation/onboarding_route_transitions.dart';
import 'features/onboarding/presentation/pages/get_started_page.dart';
import 'features/onboarding/presentation/pages/register_start_onboarding_page.dart';
import 'features/profile/presentation/pages/profile_setup_page.dart';
import 'features/ride_complete/presentation/pages/rate_experience_screen.dart';
import 'features/ride_complete/presentation/pages/ride_completed_screen.dart';
import 'features/city_vehicle/city_selection/presentation/pages/city_selection_screen.dart';
import 'features/city_vehicle/city_selection/presentation/model/city_model.dart';
import 'features/city_vehicle/vehicle_selection/presentation/pages/vehicle_selection_screen.dart';
import 'features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';
import 'features/city_vehicle/vehicle_details/presentation/pages/vehicle_details_screen.dart';
import 'features/document_verify/presentation/pages/verification_screen.dart';
import 'features/documents/presentation/pages/document_upload_screen.dart';
import 'features/documents/presentation/pages/verification_submitted_screen.dart';

class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  late final Future<RegistrationProgress> _progressFuture =
      RegistrationProgressStore.load();
  late final Future<HomeTripResumeStage> _tripResumeFuture =
      HomeTripResumeStore.loadStage();
  late final Future<bool> _forceHomeFuture =
      HomeTripResumeStore.consumeForceHomeOnNextLaunch();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _forceHomeFuture,
      builder: (context, forceHomeSnapshot) {
        if (forceHomeSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool forceHome = forceHomeSnapshot.data ?? false;
        if (forceHome && Env.mockApi) {
          unawaited(HomeTripResumeStore.clear());
          return _buildHomeLanding();
        }

        return FutureBuilder<HomeTripResumeStage>(
          future: _tripResumeFuture,
          builder: (context, tripSnapshot) {
            if (tripSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final tripStage = tripSnapshot.data ?? HomeTripResumeStage.none;
            if (tripStage != HomeTripResumeStage.none) {
              final bool shouldResumeRideStage =
                  !Env.mockApi && Env.resumeRideFromSavedStage;
              if (!shouldResumeRideStage) {
                unawaited(HomeTripResumeStore.clear());
                return _buildHomeLanding();
              }
              return _buildTripResume(tripStage);
            }

            return FutureBuilder<RegistrationProgress>(
              future: _progressFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final progress = snapshot.data ?? RegistrationProgress.empty();
                if (progress.shouldResume) {
                  return _buildRegistrationResume(progress);
                }

                if (progress.onboardingSeen) {
                  return const LoginFormPage();
                }

                return _buildGetStarted(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGetStarted(BuildContext context) {
    return GetStartedPage(
      onGetStarted: () {
        RegistrationProgressStore.markOnboardingSeen();
        Navigator.of(
          context,
        ).push(onboardingSlideRoute(const BikeTaxiOnboardingPage()));
      },
      onSignIn: () {
        RegistrationProgressStore.markOnboardingSeen();
        Navigator.of(context).push(loginFormRoute());
      },
    );
  }

  Widget _buildHomeLanding() {
    return BlocProvider<DriverCubit>(
      create: (_) => DriverCubit(),
      child: const HomeScreen(),
    );
  }

  Widget _buildRegistrationResume(RegistrationProgress progress) {
    switch (progress.step) {
      case RegistrationStep.profileSetup:
        return const ProfileSetupPage();
      case RegistrationStep.citySelection:
        return const CitySelectionScreen();
      case RegistrationStep.vehicleSelection:
        {
          final city = _resolveCity(progress.cityId);
          if (city == null) {
            return const CitySelectionScreen();
          }
          return VehicleSelectionScreen(selectedCity: city);
        }
      case RegistrationStep.vehicleDetails:
        {
          final vehicleType = _resolveVehicleType(progress.vehicleType);
          if (vehicleType == null) {
            final city = _resolveCity(progress.cityId);
            if (city == null) return const CitySelectionScreen();
            return VehicleSelectionScreen(selectedCity: city);
          }
          return VehicleDetailsScreen(vehicleType: vehicleType);
        }
      case RegistrationStep.verification:
        return const VerificationScreen();
      case RegistrationStep.documentUpload:
        return DocumentUploadScreen(
          initialStepIndex: progress.documentStepIndex ?? 0,
        );
      case RegistrationStep.verificationSubmitted:
        return const VerificationSubmittedScreen();
      case RegistrationStep.none:
        return _buildGetStarted(context);
    }
  }

  Widget _buildTripResume(HomeTripResumeStage stage) {
    switch (stage) {
      case HomeTripResumeStage.none:
        return _buildGetStarted(context);
      case HomeTripResumeStage.availableOrders:
        return const AvailableOrdersPage();
      case HomeTripResumeStage.rideArrived:
        return const RideArrivedPage();
      case HomeTripResumeStage.enterRideCode:
        return const EnterRideCodePage();
      case HomeTripResumeStage.passengerOnboard:
        return const PassengerOnboardPage();
      case HomeTripResumeStage.tripNavigation:
        return const TripNavigationPage(
          dropPoint: LatLng(13.0744, 80.2241),
        );
      case HomeTripResumeStage.rideCompleted:
        return const RideCompletedScreen();
      case HomeTripResumeStage.rateExperience:
        return const RateExperienceScreen();
    }
  }

  City? _resolveCity(String? cityId) {
    if (cityId == null || cityId.isEmpty) return null;
    for (final city in kAllCities) {
      if (city.id == cityId) return city;
    }
    for (final city in kFeaturedCities) {
      if (city.id == cityId) return city;
    }
    return null;
  }

  VehicleType? _resolveVehicleType(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final type in VehicleType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }
}
