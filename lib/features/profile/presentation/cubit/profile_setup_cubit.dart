import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/profile/domain/services/profile_validation_service.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit({required ProfileValidationService validationService})
      : _validationService = validationService,
        super(const ProfileSetupState());

  final ProfileValidationService _validationService;

  void setInitial({
    required String name,
    required String gender,
    required String refer,
    required String emergencyContact,
  }) {
    emit(
      state.copyWith(
        name: name,
        gender: gender,
        refer: refer,
        emergencyContact: emergencyContact,
        showValidation: false,
        submitRequested: false,
        clearSubmission: true,
      ),
    );
  }

  void updateName(String value) {
    emit(
      state.copyWith(
        name: value,
        showValidation: false,
        submitRequested: false,
      ),
    );
  }

  void updateGender(String value) {
    emit(
      state.copyWith(
        gender: value,
        showValidation: false,
        submitRequested: false,
      ),
    );
  }

  void updateDob(String value) {
    emit(
      state.copyWith(
        dob: value,
        showValidation: false,
        submitRequested: false,
      ),
    );
  }

  void updateRefer(String value) {
    emit(
      state.copyWith(
        refer: value,
        showValidation: false,
        submitRequested: false,
      ),
    );
  }

  void updateEmergencyContact(String value) {
    emit(
      state.copyWith(
        emergencyContact: value,
        showValidation: false,
        submitRequested: false,
      ),
    );
  }

  void submit() {
    final nameError = _validationService.validateName(state.name);
    final genderError = _validationService.validateGender(state.gender);
    final dobError = _validationService.validateDob(state.dob);
    final emergencyError = _validationService.validateEmergencyContact(
      state.emergencyContact,
    );

    final hasError =
        nameError != null ||
        genderError != null ||
        dobError != null ||
        emergencyError != null;

    if (hasError) {
      emit(
        state.copyWith(
          nameError: nameError,
          genderError: genderError,
          dobError: dobError,
          emergencyContactError: emergencyError,
          showValidation: true,
          submitRequested: false,
          clearSubmission: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        nameError: null,
        genderError: null,
        dobError: null,
        emergencyContactError: null,
        showValidation: true,
        submitRequested: true,
        submission: ProfileSubmission(
          name: state.name.trim(),
          gender: state.gender.trim(),
          refer: state.refer.trim(),
          emergencyContact: state.emergencyContact.trim(),
        ),
      ),
    );
  }

  void consumeSubmit() {
    emit(
      state.copyWith(
        submitRequested: false,
      ),
    );
  }
}
