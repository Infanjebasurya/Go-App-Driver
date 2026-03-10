import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/app_cleanup_service.dart';
import 'package:goapp/core/storage/registration_progress_store.dart';
import 'package:goapp/core/storage/ride_history_store.dart';
import 'package:goapp/core/storage/user_cache_model.dart';
import 'package:goapp/core/storage/user_cache_store.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/model/city_model.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/pages/city_selection_screen.dart';
import 'package:goapp/features/city_vehicle/vehicle_details/presentation/pages/vehicle_details_screen.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/model/vehicle_model.dart';
import 'package:goapp/features/city_vehicle/vehicle_selection/presentation/pages/vehicle_selection_screen.dart';
import 'package:goapp/features/document_verify/presentation/pages/verification_screen.dart';
import 'package:goapp/features/documents/presentation/pages/document_upload_screen.dart';
import 'package:goapp/features/documents/presentation/pages/verification_submitted_screen.dart';
import 'package:goapp/features/onboarding/presentation/navigation/onboarding_route_transitions.dart';
import 'package:goapp/features/onboarding/presentation/pages/get_started_page.dart';
import 'package:goapp/features/onboarding/presentation/pages/register_start_onboarding_page.dart';
import 'package:goapp/features/profile/presentation/pages/profile_setup_page.dart';

import 'features/home/presentation/cubit/driver_status_cubit.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'package:goapp/core/theme/app_colors.dart';

class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  late final Future<_EntryBootstrap> _bootstrapFuture = _loadBootstrap();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EntryBootstrap>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data ?? const _EntryBootstrap();
        if (data.user != null) {
          return _buildResumeScreen(
            data.progress ?? RegistrationProgress.empty(),
          );
        }
        if (data.onboardingSeen) {
          return const LoginFormPage();
        }
        return _buildGetStarted(context);
      },
    );
  }

  Widget _buildResumeScreen(RegistrationProgress progress) {
    switch (progress.step) {
      case RegistrationStep.profileSetup:
        return const ProfileSetupPage();
      case RegistrationStep.citySelection:
        return const CitySelectionScreen();
      case RegistrationStep.vehicleSelection:
        final selectedCity = kAllCities.firstWhere(
          (city) => city.id == progress.cityId,
          orElse: () => const City(id: 'chennai', name: 'Chennai'),
        );
        return VehicleSelectionScreen(selectedCity: selectedCity);
      case RegistrationStep.vehicleDetails:
        final type = _vehicleTypeFromName(progress.vehicleType);
        if (type != null) {
          return VehicleDetailsScreen(vehicleType: type);
        }
        return const CitySelectionScreen();
      case RegistrationStep.verification:
        return const VerificationScreen();
      case RegistrationStep.documentUpload:
        return DocumentUploadScreen(
          initialStepIndex: progress.documentStepIndex ?? 0,
        );
      case RegistrationStep.verificationSubmitted:
        return const VerificationSubmittedScreen();
      case RegistrationStep.home:
      case RegistrationStep.none:
        return BlocProvider<DriverCubit>(
          create: (_) => DriverCubit(),
          child: const HomeScreen(),
        );
    }
  }

  VehicleType? _vehicleTypeFromName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final type in VehicleType.values) {
      if (type.name == name) return type;
    }
    return null;
  }

  Widget _buildGetStarted(BuildContext context) {
    return GetStartedPage(
      onGetStarted: () {
        RegistrationProgressStore.markOnboardingSeen();
        Navigator.of(context).push(
          onboardingSlideRoute(const BikeTaxiOnboardingPage()),
        );
      },
      onSignIn: () {
        RegistrationProgressStore.markOnboardingSeen();
        Navigator.of(context).pushAndRemoveUntil(
          loginFormRoute(),
          (_) => false,
        );
      },
    );
  }

  Future<_EntryBootstrap> _loadBootstrap() async {
    final user = await UserCacheStore.load();
    final progress = await RegistrationProgressStore.load();
    const cleanupService = AppCleanupService();
    if ((user == null || !progress.otpVerified) && !progress.onboardingSeen) {
      await RideHistoryStore.clearAll();
      await cleanupService.clearKycDraftsAndSensitiveFiles();
      return const _EntryBootstrap(
        onboardingSeen: false,
      );
    }
    if (user == null || !progress.otpVerified) {
      await RideHistoryStore.clearAll();
      await cleanupService.clearKycDraftsAndSensitiveFiles();
      return const _EntryBootstrap(
        onboardingSeen: true,
      );
    }
    return _EntryBootstrap(
      user: user,
      onboardingSeen: progress.onboardingSeen,
      progress: progress,
    );
  }
}

class _EntryBootstrap {
  const _EntryBootstrap({
    this.user,
    this.onboardingSeen = false,
    this.progress,
  });

  final LocalUserCacheModel? user;
  final bool onboardingSeen;
  final RegistrationProgress? progress;
}


