import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/error/failures.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/widgets/app_text_field.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/pages/city_selection_screen.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:goapp/features/profile/domain/services/profile_validation_service.dart';
import 'package:goapp/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_event.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_state.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_cubit.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_state.dart';
import 'package:goapp/features/profile/presentation/widgets/either.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key, this.allowBack = false});

  final bool allowBack;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _referController = TextEditingController();
  final _emergencyController = TextEditingController();

  bool _prefilled = false;
  late final ProfileSetupCubit _cubit;
  late final ProfileBloc _profileBloc;
  late final bool _ownsProfileBloc;
  _FakeProfileRepository? _fallbackRepository;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileSetupCubit(validationService: ProfileValidationService());
    try {
      _profileBloc = context.read<ProfileBloc>();
      _ownsProfileBloc = false;
    } catch (_) {
      _fallbackRepository = _FakeProfileRepository();
      _profileBloc = ProfileBloc(
        CreateProfileUseCase(_fallbackRepository!),
        GetCachedProfileUseCase(_fallbackRepository!),
        autoLoad: false,
      );
      _ownsProfileBloc = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = _profileBloc.state;
      if (state is ProfileSuccess) {
        _prefillFromProfile(state.profile);
      } else {
        _profileBloc.add(const ProfileRequested());
      }
    });
    if (!const bool.fromEnvironment('FLUTTER_TEST')) {
      unawaited(_requestNotificationPermissionOnce());
    }
  }

  Future<void> _requestNotificationPermissionOnce() async {
    return;
  }

  @override
  void dispose() {
    _cubit.close();
    if (_ownsProfileBloc) {
      _profileBloc.close();
    }
    _nameController.dispose();
    _referController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  void _prefillFromProfile(Profile profile) {
    if (_prefilled) return;
    _prefilled = true;
    _nameController.text = profile.name;
    _referController.text = profile.refer;
    _emergencyController.text = profile.emergencyContact;
    _cubit.setInitial(
      name: profile.name,
      gender: profile.gender,
      refer: profile.refer,
      emergencyContact: profile.emergencyContact,
    );
  }

  static const List<String> _genders = [
    'Male',
    'Female',
    'Others',
    'Prefer not to say',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatDob(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  Future<void> _openGenderSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: _cubit,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.surfaceShadow,
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.handleGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Select Gender',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          for (final gender in _genders)
                            InkWell(
                              onTap: () {
                                context.read<ProfileSetupCubit>().updateGender(
                                  gender,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        gender,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      state.gender == gender
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: state.gender == gender
                                          ? AppColors.emerald
                                          : AppColors.inactive,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDobSheet(BuildContext context) async {
    final formState = _cubit.state;
    final now = DateTime.now();
    final maxDob = DateTime(now.year - 10, now.month, now.day);
    DateTime tempDate = DateTime(now.year - 20, now.month, now.day);
    if (formState.dob.isNotEmpty) {
      final parts = formState.dob.split(' ');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 15;
        final monthIndex = _months.indexOf(parts[1]);
        final year = int.tryParse(parts[2]) ?? 1991;
        if (monthIndex >= 0) {
          tempDate = DateTime(year, monthIndex + 1, day);
        }
      }
    }
    if (tempDate.isAfter(maxDob)) {
      tempDate = maxDob;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      builder: (sheetContext) {
        final screenHeight = MediaQuery.sizeOf(sheetContext).height;
        final pickerHeight = (screenHeight * 0.34).clamp(170.0, 240.0);
        return AnimatedPadding(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.surfaceShadow,
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.handleGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Select Date',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _cubit.updateDob(_formatDob(tempDate));
                                Navigator.of(sheetContext).pop();
                              },
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: AppColors.emerald,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: pickerHeight,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: tempDate,
                            minimumYear: 1940,
                            maximumYear: DateTime.now().year,
                            maximumDate: maxDob,
                            onDateTimeChanged: (value) {
                              setModalState(() => tempDate = value);
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Identity verification required for premium service',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.noteText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 25 / 2,
        color: AppColors.black,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _lineField({
    required String label,
    required Widget child,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.validationRed,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>.value(
      value: _profileBloc,
      child: BlocProvider<ProfileSetupCubit>.value(
        value: _cubit,
        child: PopScope(
          canPop: widget.allowBack,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppAppBar(title: 'GoApp', backEnabled: false, onBack: null),
            body: MultiBlocListener(
              listeners: [
                BlocListener<ProfileBloc, ProfileState>(
                  listener: (context, state) async {
                    if (state is ProfileSuccess) {
                      final formState = context.read<ProfileSetupCubit>().state;
                      final hasSubmission = formState.submission != null;
                      if (!hasSubmission) {
                        _prefillFromProfile(state.profile);
                        return;
                      }
                      if (widget.allowBack) {
                        Navigator.of(context).pop();
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const CitySelectionScreen(),
                        ),
                      );
                    }
                  },
                ),
                BlocListener<ProfileSetupCubit, ProfileSetupState>(
                  listenWhen: (previous, current) =>
                      previous.submitRequested != current.submitRequested,
                  listener: (context, state) {
                    if (!state.submitRequested || state.submission == null) {
                      return;
                    }
                    _profileBloc.add(
                      ProfileSubmitted(
                        name: state.submission!.name,
                        gender: state.submission!.gender,
                        refer: state.submission!.refer,
                        emergencyContact: state.submission!.emergencyContact,
                      ),
                    );
                    context.read<ProfileSetupCubit>().consumeSubmit();
                  },
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
                  builder: (context, formState) {
                    final isGenderEmpty = formState.gender.trim().isEmpty;
                    final displayGender = isGenderEmpty
                        ? 'Select gender'
                        : formState.gender;
                    final isDobEmpty = formState.dob.trim().isEmpty;
                    final displayDob = isDobEmpty
                        ? 'e.g., 12 July 1985'
                        : formState.dob;
                    return SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 16),
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            'Complete Your Profile',
                            style: TextStyle(
                              fontSize: 64 / 2,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Welcome to the inner circle. Let’s personalize\nyour journey to premium Earnings.',
                            style: TextStyle(
                              fontSize: 27 / 2,
                              height: 1.45,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _lineField(
                            label: 'Full Name',
                            errorText: formState.showValidation
                                ? formState.nameError
                                : null,
                            child: AppTextField(
                              controller: _nameController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Za-z ]'),
                                ),
                              ],
                              label: '',
                              hint: 'e.g., Yogesh S',
                              borderless: true,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: const TextStyle(
                                color: AppColors.inputHint,
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w500,
                              ),
                              textStyle: const TextStyle(
                                color: AppColors.black,
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: context
                                  .read<ProfileSetupCubit>()
                                  .updateName,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _lineField(
                            label: 'Gender',
                            errorText: formState.showValidation
                                ? formState.genderError
                                : null,
                            child: InkWell(
                              onTap: () => _openGenderSheet(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayGender,
                                        style: TextStyle(
                                          color: isGenderEmpty
                                              ? AppColors.inputHint
                                              : AppColors.black,
                                          fontSize: 30 / 2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.iconMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _lineField(
                            label: 'Date of Birth',
                            errorText: formState.showValidation
                                ? formState.dobError
                                : null,
                            child: InkWell(
                              onTap: () => _openDobSheet(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayDob,
                                        style: TextStyle(
                                          color: isDobEmpty
                                              ? AppColors.inputHint
                                              : AppColors.black,
                                          fontSize: 30 / 2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 20,
                                      color: AppColors.iconMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _lineField(
                            label: 'Referral Code (optional)',
                            child: AppTextField(
                              controller: _referController,
                              label: '',
                              hint: 'Enter code if appilcable',
                              borderless: true,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: const TextStyle(
                                color: AppColors.inputHint,
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w500,
                              ),
                              textStyle: const TextStyle(
                                color: AppColors.black,
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              context.read<ProfileSetupCubit>().submit();
                            },
                            child: const Text(
                              'Save & Continue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is! ProfileFailure) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.red,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.helperText,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'By tapping Save & Continue, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeProfileRepository implements ProfileRepository {
  Profile? _cached;

  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String refer,
    required String emergencyContact,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cached = Profile(
      id: 'demo-profile',
      name: name,
      gender: gender,
      refer: refer,
      emergencyContact: emergencyContact,
    );
    return Right(_cached!);
  }

  @override
  Future<Either<Failure, Profile?>> getCachedProfile() async {
    return Right(_cached);
  }
}
