import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/user_cache_model.dart';
import 'package:goapp/core/storage/user_cache_store.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/profile/data/repositories/local_profile_repository.dart';
import 'package:goapp/features/auth/presentation/widgets/app_text_field.dart';
import 'package:goapp/features/auth/presentation/widgets/appbar.dart';
import 'package:goapp/features/city_vehicle/city_selection/presentation/pages/city_selection_screen.dart';
import 'package:goapp/features/profile/domain/entities/profile.dart';
import 'package:goapp/features/profile/domain/services/profile_validation_service.dart';
import 'package:goapp/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_event.dart';
import 'package:goapp/features/profile/presentation/bloc/profile_state.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_cubit.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_state.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/widgets/keyboard_aware_bottom.dart';
import 'package:goapp/core/widgets/shadow_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key, this.allowBack = false});

  final bool allowBack;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  static final Uri _termsUri = Uri.parse('https://sybrox.com/about');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _referController = TextEditingController();
  final _emergencyController = TextEditingController();
  late final TapGestureRecognizer _termsTap;

  bool _prefilled = false;
  bool _didNavigate = false;
  late final ProfileSetupCubit _cubit;
  late final ProfileBloc _profileBloc;
  late final bool _ownsProfileBloc;
  LocalProfileRepository? _fallbackRepository;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = _openTermsOfService;
    _cubit = ProfileSetupCubit(validationService: ProfileValidationService());
    try {
      _profileBloc = context.read<ProfileBloc>();
      _ownsProfileBloc = false;
    } catch (_) {
      _fallbackRepository = LocalProfileRepository();
      _profileBloc = ProfileBloc(
        CreateProfileUseCase(_fallbackRepository!),
        GetCachedProfileUseCase(_fallbackRepository!),
        autoLoad: false,
      );
      _ownsProfileBloc = true;
    }
    _cubit.setInitial(
      name: '',
      email: '',
      gender: '',
      dob: '',
      refer: '',
      emergencyContact: '',
    );
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
    _termsTap.dispose();
    _cubit.close();
    if (_ownsProfileBloc) {
      _profileBloc.close();
    }
    _nameController.dispose();
    _emailController.dispose();
    _referController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _openTermsOfService() async {
    final launched = await launchUrl(
      _termsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || launched) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open link')));
  }

  void _prefillFromProfile(Profile profile) {
    if (_prefilled) return;
    _prefilled = true;
    final name = _nameController.text.isNotEmpty
        ? _nameController.text
        : profile.name;
    final email = _emailController.text.isNotEmpty
        ? _emailController.text
        : (profile.email ?? '');
    final refer = _referController.text.isNotEmpty
        ? _referController.text
        : profile.refer;
    final emergency = _emergencyController.text.isNotEmpty
        ? _emergencyController.text
        : profile.emergencyContact;
    _nameController.text = name;
    _emailController.text = email;
    _referController.text = refer;
    _emergencyController.text = emergency;
    _cubit.setInitial(
      name: name,
      email: email,
      gender: profile.gender,
      dob: profile.dob ?? '',
      refer: refer,
      emergencyContact: emergency,
    );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _referController.clear();
    _emergencyController.clear();
    _prefilled = false;
    _cubit.setInitial(
      name: '',
      email: '',
      gender: '',
      dob: '',
      refer: '',
      emergencyContact: '',
    );
    unawaited(TextFieldStore.remove('profile_setup.name'));
    unawaited(TextFieldStore.remove('profile_setup.email'));
    unawaited(TextFieldStore.remove('profile_setup.gender'));
    unawaited(TextFieldStore.remove('profile_setup.dob'));
    unawaited(TextFieldStore.remove('profile_setup.refer'));
    unawaited(TextFieldStore.remove('profile_setup.emergency'));
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
            backgroundColor: AppColors.white,
            appBar: AppAppBar(title: 'GoApp', backEnabled: false, onBack: null),
            body: MultiBlocListener(
              listeners: [
                BlocListener<ProfileBloc, ProfileState>(
                  listener: (context, state) async {
                    if (state is ProfileSuccess) {
                      if (_didNavigate) return;
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
                      await UserCacheStore.save(
                        LocalUserCacheModel(
                          id: state.profile.id,
                          fullName: formState.name.trim(),
                          gender: formState.gender.trim(),
                          referCode: formState.refer.trim(),
                          emergencyContact: formState.emergencyContact.trim(),
                          email: formState.email.trim().isEmpty
                              ? null
                              : formState.email.trim(),
                          phone: state.profile.phone,
                          dob: formState.dob.trim().isEmpty
                              ? null
                              : formState.dob.trim(),
                          rating: state.profile.rating,
                          totalTrips: state.profile.totalTrips,
                          totalYears: state.profile.totalYears,
                        ),
                      );
                      if (!context.mounted) return;
                      _didNavigate = true;
                      _clearForm();
                      Navigator.of(context)
                          .pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const CitySelectionScreen(),
                            ),
                          )
                          .then((_) {
                            if (!mounted) return;
                            _didNavigate = false;
                          });
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
                        email: state.submission!.email,
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
                              textCapitalization: TextCapitalization.words,
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
                            label: 'Email',
                            errorText: formState.showValidation
                                ? formState.emailError
                                : null,
                            child: AppTextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              label: '',
                              hint: 'e.g., name@example.com',
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
                                  .updateEmail,
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
                              hint: 'Enter code if applicable',
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
                                  .updateRefer,
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
            bottomNavigationBar: KeyboardAwareBottom(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
                    builder: (context, formState) {
                      final isFormValid = context
                          .read<ProfileSetupCubit>()
                          .isFormValid;
                      return BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          if (state is ProfileLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ShadowButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              onPressed: state is ProfileLoading
                                  ? null
                                  : () {
                                      if (!isFormValid) {
                                        context
                                            .read<ProfileSetupCubit>()
                                            .submit();
                                        return;
                                      }
                                      context
                                          .read<ProfileSetupCubit>()
                                          .submit();
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
                  Padding(
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
                            recognizer: _termsTap,
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
    );
  }
}



