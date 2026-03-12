import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/app_colors.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_cubit.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_state.dart';

class ProfileAddressSection extends StatelessWidget {
  const ProfileAddressSection({
    super.key,
    required this.formState,
    required this.onOpenGender,
    required this.onOpenDob,
  });

  final ProfileSetupState formState;
  final VoidCallback onOpenGender;
  final VoidCallback onOpenDob;

  @override
  Widget build(BuildContext context) {
    final isGenderEmpty = formState.gender.trim().isEmpty;
    final displayGender = isGenderEmpty ? 'Select gender' : formState.gender;
    final isDobEmpty = formState.dob.trim().isEmpty;
    final displayDob = isDobEmpty ? 'e.g., 12 July 1985' : formState.dob;

    return Column(
      children: [
        _lineField(
          label: 'Gender',
          errorText: formState.showValidation ? formState.genderError : null,
          child: InkWell(
            onTap: onOpenGender,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayGender,
                      style: TextStyle(
                        color: isGenderEmpty ? AppColors.inputHint : AppColors.black,
                        fontSize: 15,
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
          errorText: formState.showValidation ? formState.dobError : null,
          child: InkWell(
            onTap: onOpenDob,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayDob,
                      style: TextStyle(
                        color: isDobEmpty ? AppColors.inputHint : AppColors.black,
                        fontSize: 15,
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
      ],
    );
  }
}

Future<void> showGenderSheet(
  BuildContext context, {
  required ProfileSetupCubit cubit,
  required List<String> genders,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.white,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
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
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: AppColors.emerald,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        for (final gender in genders)
                          InkWell(
                            onTap: () {
                              context.read<ProfileSetupCubit>().updateGender(gender);
                              Navigator.of(sheetContext).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
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

Future<void> showDobSheet(
  BuildContext context, {
  required ProfileSetupCubit cubit,
  required List<String> months,
  required String Function(DateTime) formatDob,
}) async {
  final formState = cubit.state;
  final now = DateTime.now();
  final maxDob = DateTime(now.year - 10, now.month, now.day);
  DateTime tempDate = DateTime(now.year - 20, now.month, now.day);
  if (formState.dob.isNotEmpty) {
    final parts = formState.dob.split(' ');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]) ?? 15;
      final monthIndex = months.indexOf(parts[1]);
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
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
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
                              cubit.updateDob(formatDob(tempDate));
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
      fontSize: 12.5,
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
